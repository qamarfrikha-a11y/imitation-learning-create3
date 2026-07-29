#!/bin/bash
# Automatise N essais d'evaluation quantitative du modele BC.
# Relance la simulation Gazebo au complet avant CHAQUE essai, pour garantir
# que /odom et la position reelle repartent parfaitement synchronisees.
#
# Usage : ./run_evaluation.sh [nombre_essais]

set -e

N_TRIALS="${1:-15}"
WS_DIR="$HOME/stage_imitation_learning/ros2_ws"
RESULTS_CSV="$HOME/stage_imitation_learning/results/evaluation.csv"

source /opt/ros/humble/setup.bash
source "$WS_DIR/install/setup.bash"
export LIBGL_ALWAYS_SOFTWARE=1

mkdir -p "$(dirname "$RESULTS_CSV")"
rm -f "$RESULTS_CSV"

echo "=== Evaluation quantitative : $N_TRIALS essais ==="

for i in $(seq 1 "$N_TRIALS"); do
    echo ""
    echo ">>> Essai $i / $N_TRIALS"

    killall -9 gzserver gzclient gazebo 2>/dev/null || true
    sleep 2

    ros2 launch create3_lidar_description create3_lidar_full.launch.py \
        use_rviz:=false > /tmp/eval_sim_log_$i.txt 2>&1 &
    SIM_PID=$!
    # Attente active que le controller_manager soit pret
    echo "Attente du controller_manager..."
    for attempt in $(seq 1 40); do
        if ros2 service list 2>/dev/null | grep -q "/controller_manager/list_controllers"; then
            echo "controller_manager pret."
            break
        fi
        sleep 2
    done

    # Attente specifique que diffdrive_controller (le vrai controle des roues) soit actif
    echo "Attente du diffdrive_controller..."
    for attempt in $(seq 1 20); do
        if ros2 topic list 2>/dev/null | grep -q "/diffdrive_controller/cmd_vel_unstamped"; then
            echo "diffdrive_controller pret."
            break
        fi
        sleep 1
    done
    sleep 3   # marge de securite supplementaire

    ros2 param set /motion_control safety_override full > /dev/null 2>&1 || true
    python3 "$WS_DIR/src/create3_il/create3_il/eval_trial_node.py" "$i" \
        > /tmp/eval_trial_log_$i.txt 2>&1 || true

    # Tue le processus launch ET tous ses enfants, plus tout residu Gazebo/ROS
    kill -9 "$SIM_PID" 2>/dev/null || true
    pkill -9 -f "gzserver" 2>/dev/null || true
    pkill -9 -f "gzclient" 2>/dev/null || true
    pkill -9 -f "ros2 launch" 2>/dev/null || true
    pkill -9 -f "spawner" 2>/dev/null || true
    pkill -9 -f "robot_state_publisher" 2>/dev/null || true
    pkill -9 -f "motion_control" 2>/dev/null || true
    sleep 4

    # Verification qu'il ne reste plus aucun noeud du robot avant l'essai suivant
    if ros2 node list 2>/dev/null | grep -q "create3\|motion_control"; then
        echo "ATTENTION: des noeuds residuels sont encore actifs, pause supplementaire"
        sleep 5
    fi


done

echo ""
echo "=== Termine. Resultats dans $RESULTS_CSV ==="
echo "Lance maintenant : python3 ~/stage_imitation_learning/scripts/summarize_evaluation.py"
