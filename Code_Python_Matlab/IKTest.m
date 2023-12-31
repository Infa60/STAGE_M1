% This example script runs multiple inverse kinematics trials for the model Subject01. 
% All input files are in the folder ../Matlab/testData/Subject01
% To see the results load the model and ik output in the GUI.

%% Pull in the modeling classes straight from the OpenSim distribution
function setupAndRunIKBatchExample(source, destination)

%% Example
% source = 'C:\Users\mhossein\OneDrive - The University of Melbourne\Projects\TargetSearch\OpenSim_requirments\IKXMLs_TargetSerach';
% destination = 'C:\Users\mhossein\OneDrive - The University of Melbourne\Projects\TargetSearch\JS\';
% setupAndRunIKBatchExample(source, destination)



%% Now Copy the relvenat xml file for this person.

trc_data_folder = fullfile(destination,'trcResults');
results_folder = fullfile(destination,'IKResults');
genericSetupPath = fullfile(destination,'IKSetup');
genericSetupForIK = 'IK_HBM_Setup.xml';
copyfile(source, genericSetupPath)
modelFile = 'subject01_simbody.osim';
modelFilePath = fullfile(destination,'ScaledModel');



import org.opensim.modeling.*

% move to directory where this subject's files are kept
% Dir = 'C:\Users\mhossein\OneDrive - The University of Melbourne\Summer Internships 2018\Data\DF1';
% Dir = 'C:\Users\mhossein\OneDrive - The University of Melbourne\Summer Internships 2018\Data\CB1\VICON\CB1';
% subjectDir = uigetdir(Dir, 'Select the folder that contains the current subject data');

% Go to the folder in the subject's folder where .trc files are
% trc_data_folder = uigetdir(subjectDir, 'Select the folder that contains the marker data files in .trc format.');

% specify where results will be printed.
% results_folder = uigetdir(subjectDir, 'Select the folder where the IK Results will be printed.');

% Get and operate on the files
% Choose a generic setup file to work from
% [genericSetupForIK,genericSetupPath,FilterIndex] = ...
%     uigetfile('*.xml','Pick the a generic setup file to for this subject/model as a basis for changes.');
setup = fullfile(genericSetupPath, genericSetupForIK);
% ikTool = InverseKinematicsTool([genericSetupPath genericSetupForIK]);
ikTool = InverseKinematicsTool(setup);

% Get the model
% [modelFile,modelFilePath,FilterIndex] = ...
%     uigetfile('*.osim','Pick the the model file to be used.');

% Load the model and initialize
model = Model(fullfile(modelFilePath, modelFile));
model.initSystem();

% Tell Tool to use the loaded model
ikTool.setModel(model);

trialsForIK = dir(fullfile(trc_data_folder, '*.trc'));

nTrials = size(trialsForIK);

%% Loop through the trials
import org.opensim.modeling.*
for trial= 1:nTrials
    
    % Get the name of the file for this trial
    markerFile = trialsForIK(trial).name;
    
    % Create name of trial from .trc file name
    name = regexprep(markerFile,'.trc','');
    fullpath = fullfile(trc_data_folder, markerFile);
    
    % Get trc data to determine time range
    markerData = MarkerData(fullpath);
    
    % Get initial and intial time 
    initial_time = markerData.getStartFrameTime();
    final_time = markerData.getLastFrameTime();
    
    % Setup the ikTool for this trial
    ikTool.setName(name);ikTool.setModel(model);
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
    ikTool.run();
    
end