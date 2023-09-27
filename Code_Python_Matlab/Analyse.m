% Charger la bibliothèque OpenSim
import org.opensim.modeling.*;

destination = '/Users/mathieubourgeois/Desktop/Traitement/';




destinationScale = strcat(destination, 'Settings/');
trc_data_folder = fullfile(destination,'Data');
results_folder = fullfile(destination,'IKResults');
genericSetupPath = fullfile(destination,'Settings');
genericSetupForIK = 'IK_Settings.xml';
modelFilePath = fullfile(destination,'ScaleModel');

%copyfile(destination, genericSetupPath) copie les fichier de destination
%dans genericSetupPath

setup = fullfile(genericSetupPath, genericSetupForIK);
% ikTool = InverseKinematicsTool([genericSetupPath genericSetupForIK]);
ikTool = InverseKinematicsTool(setup);


% Se placer dans le dossier ScalingSetup pour exécuter l'outil d'ajustement de l'échelle
cd(destinationScale)

% Instancier l'outil d'ajustement de l'échelle
scaleTool = ScaleTool('Scale.xml');

cd(destination)

% Changer le modèle si nécessaire
scaleTool.getGenericModelMaker.setModelFileName('M2S_model_complet.osim');

% Exécuter l'outil d'ajustement de l'échelle
scaleTool.run()

%Récupération du nombre de fichier à traiter dans Data
trialsForIK = dir(fullfile(trc_data_folder, '*.trc'));
nTrials = size(trialsForIK);

%% Loop through the trials
import org.opensim.modeling.*

model_scale = Model('M2S_model_complet_scale.osim');

for trial= 1:nTrials

% Get the name of the file for this trial
    markerFile = trialsForIK(trial).name;
    
    % Create name of trial from .trc file name, le chemin complet
    name = regexprep(markerFile,'.trc','');
    fullpath = fullfile(trc_data_folder, markerFile);
   
    % Get trc data to determine time range
    markerData = MarkerData(fullpath);

    % Get initial and final time 
    initial_time = markerData.getStartFrameTime();
    final_time = markerData.getLastFrameTime();

    % Setup the ikTool for this trial
    ikTool.setName(name);ikTool.setModel(model_scale);
    ikTool.setMarkerDataFileName(fullpath);
    ikTool.setStartTime(initial_time);
    ikTool.setEndTime(final_time);
    ikTool.setOutputMotionFileName(fullfile(results_folder, [name '_ik.mot']));

    % Save the settings in a setup file
    outfile = ['Setup_IK_' name '.xml'];
    ikTool.print(fullfile(genericSetupPath, outfile));

    cd(results_folder)
    fprintf(['Performing IK on cycle # ' num2str(trial) '\n']);
    % Run IK
    %ikTool.run();
    


end




