# Algorithmic Spatialisation with SuperCollider

In this workshop we explore different ways of working with algorithmically controlled spatialization, using SuperCollider and the Ambisonics ToolKit library. To provide an interactive layer for gestural control, we will also work with the integration of continuous data streams from various sensors. The recordings made on the first day will be used as source material and a point of departure for our experiments.

## Preparations before the workshop
### 1. Install git (if you don't have it already). This is necessary for the SuperCollider Quark system to work.
- [git](https://git-scm.com/)

### 2. Download and install the latest version of SuperCollider and the latest version of the sc3-plugins (extensions for SuperCollider):
- [SuperCollider](https://supercollider.github.io/)
- [SuperCollider sc3-plugins](https://supercollider.github.io/sc3-plugins/)

The sc3-plugins are installed by moving the folder into the Extensions folder in SuperCollider's Application Support directory. To find and open this directory, start SuperCollider and run the following line by placing your cursor on somewhere on that line and press CMD+RTN (Mac) or CTRL+RTN (Linux/Windows):

```Platform.userExtensionDir.openOS;```

This will open this folder on your system. Put the sc3-plugins folder in there

### 3. Install [Ambisonics Toolkit](https://github.com/ambisonictoolkit/atk-sc3).
- To install ATK, create a SuperCollider document and run the line:

```Quarks.install("https://github.com/ambisonictoolkit/atk-sc3.git");```

Note: if this fails for some reason (i.e. an error post in the Post window), you probably didn't install git correctly.

- After the installation you need to recompile SuperCollider's class library:
Select from the menu: 
Language --> Recompile Class Library.

- Download and install the ATK Kernels, Matrices and Soundfiles by running the following lines one by one. Wait for each process to complete before running the next:
```
Atk.downloadKernels;
Atk.downloadMatrices;
Atk.downloadSounds;
```

### 4. Install files for binaural listening:

- [Convolution files for binaural listening](https://github.com/friskgit/kmh_ls/raw/master/binaural/convol_presets.zip)
- [IEM Plug-in Suite](https://plugins.iem.at/download/)
