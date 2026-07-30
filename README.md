# 🚀 Navigation Autonome par Imitation Learning

[![ROS2](https://img.shields.io/badge/ROS2-Humble-blue)](https://docs.ros.org/en/humble/)
[![Gazebo](https://img.shields.io/badge/Gazebo-Classic%2011-green)](https://classic.gazebosim.org/)

## 📖 Présentation

Ce projet permet à un robot **iRobot Create 3** d'apprendre à naviguer de manière autonome en observant des démonstrations humaines (Imitation Learning).

**Technologies utilisées :** ROS 2, Gazebo, PyTorch

## 🤖 Robot

![Robot Create 3](media/images/robot_create3.png)

## 🎬 Démonstration vidéo

[![Vidéo](media/images/simulation_start.png)](media/videos/demo_navigation.mp4)

*Cliquez sur l'image pour voir la vidéo*

## 📊 Résultats

- ✅ **100%** de réussite (10/10 essais)
- ⏱️ Temps moyen : **58.8 secondes**
- 📏 Distance moyenne : **9.85 mètres**

## 🏗️ Architecture

![Architecture](media/images/system_architecture.png)

## 📁 Structure du projet
stage_imitation_learning/
├── configs/ # Configuration
├── data/ # Données d'entraînement
├── docs/ # Documentation
├── models/ # Modèles entraînés
├── media/ # Images et vidéos
├── ros2_ws/ # Workspace ROS 2
└── src/ # Code source

text

## 🚀 Installation

```bash
# Cloner
git clone https://github.com/VOTRE-UTILISATEUR/stage_imitation_learning.git
cd stage_imitation_learning

# Installer les dépendances
pip install -r requirements.txt

# Compiler ROS 2
cd ros2_ws
colcon build
source install/setup.bash
