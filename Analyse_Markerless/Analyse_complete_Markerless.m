%% Load OpenSim libs
import org.opensim.modeling.*

%% Création des chemins
origineC3D = '/Users/mathieubourgeois/Desktop/Analyse_Markerless/C3DFilesMarkerless';
origine = '/Users/mathieubourgeois/Desktop/Analyse_Markerless';
destination = fullfile(origine,'Traitement_Markerless');


% Charger la bibliothèque OpenSim
import org.opensim.modeling.*;

%% Déclaration des chemins importants
genericSetupIKSettings = 'IK_Settings.xml';

%% Mise à l'échelle de tous les individus 

IndivForScale = dir(fullfile(destination, 'Sujet*'));
nIndiv = size(IndivForScale);

for Indiv = 1:nIndiv

    genericSetupForScale = 'Scale_Settings.xml';
    genericSetupPathScale =fullfile(origine);

    nameIndiv = IndivForScale(Indiv).name;

    fullpathNameIndiv = fullfile(destination, nameIndiv);
    %disp(fullpathNameIndiv)
    cd(fullpathNameIndiv);

    StaticIndiv = dir(fullfile(fullpathNameIndiv, '*.trc'));
    nameStatic = StaticIndiv().name;
    fullpathStatic = fullfile(destination,nameIndiv,nameStatic);

    cd(origine);

    xml_file = 'Scale_Settings.xml';
    % Lire le fichier xml
    xml = xmlread(xml_file);
    marker_nodes = xml.getElementsByTagName('marker_file');
        for i = 0:(marker_nodes.getLength()-1)
            marker_node = marker_nodes.item(i);
            marker_node.getFirstChild().setNodeValue(fullpathStatic);
        end
    xmlwrite(xml_file, xml);

        % Lire le fichier XML
    xmlDoc = xmlread(xml_file);   
    % Trouver tous les nœuds "output_model_file"
    outputModelFiles = xmlDoc.getElementsByTagName('output_model_file');    
    % Sélectionner le deuxième nœud "output_model_file"
    secondOutputModelFile = outputModelFiles.item(1);   
    % Modifier le nœud comme souhaité
    secondOutputModelFile.getFirstChild.setData([fullpathNameIndiv,'/' nameIndiv '_scale_model.osim']);  
    % Enregistrer les modifications dans le fichier
    xmlwrite(xml_file, xmlDoc);
    
    setupScale =fullfile(genericSetupPathScale,genericSetupForScale);
    ScTool = ScaleTool(setupScale);


    %ScTool.getPathToSubject(destination);
    ScTool.setSubjectMass(60);

    cd(destination)

    % Save the settings in a setup file
    outfile = ['Scale_' nameIndiv '.xml'];
    ScTool.print(fullfile(fullpathNameIndiv, outfile));
    fprintf(['Performing Scale on cycle # ' num2str(Indiv) '\n']);

    % Run IK
    ScTool.run()

end

%% Génération du modèle à l'échelle pour chaque individu

for Indiv = 1:nIndiv
    
    nameIndiv = IndivForScale(Indiv).name;
    
    cd(nameIndiv);
    ConstructorName = ['Scale_' nameIndiv '.xml'];
    % Instancier l'outil d'ajustement de l'échelle
    scaleTool = ScaleTool(ConstructorName);
    cd(destination)
    
    modelPath = fullfile(origine,'MarkerlessModel.osim');
    % Changer le modèle si nécessaire
    scaleTool.getGenericModelMaker.setModelFileName(modelPath);
    
    % Exécuter l'outil d'ajustement de l'échelle
    scaleTool.run()

end

%% Mise en place des settings pour la cinématique inverse et génération des chemins de direction des résultats

for Indiv = 1:nIndiv
    nameIndiv = IndivForScale(Indiv).name;
    cd(nameIndiv);

    destinationIndiv = fullfile(destination, nameIndiv);

    % Créer le dossier 'Settings' s'il n'existe pas déjà
    if ~exist(fullfile(destinationIndiv, 'Settings'), 'dir')
        mkdir(fullfile(destinationIndiv, 'Settings'));
    end

    if ~exist(fullfile(destinationIndiv, 'IKResults'), 'dir')
        mkdir(fullfile(destinationIndiv, 'IKResults'));
    end
    

    % Copier le fichier IK_settings.xml dans le dossier Settings de chaque participant
    copyfile(fullfile(origine, genericSetupIKSettings), ...
             fullfile(destinationIndiv, 'Settings', 'IK_settings.xml'));

    cd(destination)
    

    
end

%% Cinématique inverse de tous les individus

for Indiv = 1:nIndiv

    nameIndiv = IndivForScale(Indiv).name;
    cd(nameIndiv);

    
    destinationIndiv = fullfile(destination, nameIndiv);

    trc_data_folder = fullfile(destinationIndiv,'Data');
    results_folder = fullfile(destinationIndiv,'IKResults');
    genericSetupPath = fullfile(destinationIndiv,'Settings');
    genericSetupForIK = 'IK_Settings.xml';


    %Récupération du nombre de fichier à traiter dans Data
    trialsForIK = dir(fullfile(trc_data_folder, '*.trc'));
    nTrials = size(trialsForIK);
    
    % Loop through the trials
    import org.opensim.modeling.*
    
    NameModelScale = [nameIndiv '_scale_model.osim'];
    model_scale = Model(NameModelScale);

    setup = fullfile(genericSetupPath, genericSetupForIK);
    % ikTool = InverseKinematicsTool([genericSetupPath genericSetupForIK]);
    ikTool = InverseKinematicsTool(setup);
    
%% Cinématique inverse de tous les essais de chaque individu

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
        ikTool.run();
        
    
    
    end

    cd(destination)

end


