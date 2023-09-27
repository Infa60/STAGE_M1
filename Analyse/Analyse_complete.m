%% Load OpenSim libs
import org.opensim.modeling.*

%% Création des chemins
origineC3D = '/Users/mathieubourgeois/Desktop/Analyse/C3DFiles';
origine = '/Users/mathieubourgeois/Desktop/Analyse';
destination = fullfile(origine,'Traitement');

%% Identification du nombre d'individu à traiter 
IndivForConvert = dir(fullfile(origineC3D, 'Sujet*'));
nIndiv = size(IndivForConvert);

for Indiv = 1:nIndiv

    nameIndiv = IndivForConvert(Indiv).name;
    cd(origineC3D)
    cd(nameIndiv);
    destinationIndiv = fullfile(origineC3D, nameIndiv);

%% Récupération du nombre de fichier à traiter pour chaque individu
    trialsForConvert = dir(fullfile(destinationIndiv, '*.c3d'));
    nTrials = size(trialsForConvert);

    destinationTrc = fullfile(destination,nameIndiv,'Data');

    for trial= 1:nTrials
        ToConvertFileName = trialsForConvert(trial).name;
        name = regexprep(ToConvertFileName,'.c3d','');
        %disp(ToConvertFileName)

        if startsWith(name, 'Static')
        % save location for static files
        destinationTrc = fullfile(destination,nameIndiv);
        else

        % save location for motion files
        destinationTrc = fullfile(destination,nameIndiv,'Data');
        end

        if ~exist(destinationTrc, 'dir')
        mkdir(destinationTrc);
        end

        filename=ToConvertFileName;
        c3dpath = fullfile(destinationIndiv,filename);
        
        c3d = osimC3D(c3dpath,1);
           
       
        % Get the number of marker trajectories
        nTrajectories = c3d.getNumTrajectories();
        % Get the marker data rate
        rMakers = c3d.getRate_marker();
        % Get the number of forces 
        nForces = c3d.getNumForces();
        % Get the force data rate
        %rForces = c3d.getRate_force();
        
        % Get Start and end time
        t0 = c3d.getStartTime();
        tn = c3d.getEndTime();
        
        % Rotate the data
        c3d.rotateData('x',-90)
        c3d.rotateData('y',180)
        %c3d.rotateData('z',180)
        
        % Get the c3d in different forms
        % Get OpenSim tables
        markerTable = c3d.getTable_markers();
        forceTable = c3d.getTable_forces();
        % Get as Matlab Structures
        [markerStruct, forceStruct] = c3d.getAsStructs();
        
        %Filter both Marker and Force Data
        % use ForceStruct and markerStruct and filter in osimC3D and then convert
        % it to obj.markers and obj.forces so how?
        
        % Write the marker and force data to file
        
        exportName = ['Transformed_' name '.trc'];
        exportPath = fullfile(destinationTrc, exportName);


        % Write marker data to trc file.
        % c3d.writeTRC()                       Write to dir of input c3d.
        % c3d.writeTRC('Walking.trc')          Write to dir of input c3d with defined file name.
        % c3d.writeTRC('C:/data/Walking.trc')  Write to defined path input path.
        c3d.writeTRC(exportPath);
        
        % Write force data to mot file.
        % c3d.writeMOT()                       Write to dir of input c3d.
        % c3d.writeMOT('Walking.mot')          Write to dir of input c3d with defined file name.
        % c3d.writeMOT('C:/data/Walking.mot')  Write to defined path input path.
        % 
        % This function assumes point and torque data are in mm and Nmm and
        % converts them to m and Nm. If your C3D is already in M and Nm,
        % comment out the internal function convertMillimeters2Meters()
         %c3d.writeMOT('test_data_forces.mot');
    end

    cd(origineC3D)

end


% Charger la bibliothèque OpenSim
import org.opensim.modeling.*;

%% Déclaration des chemins importants
destination = '/Users/mathieubourgeois/Desktop/Analyse/Traitement/';
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
    cd(nameIndiv);

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
    
    modelPath = fullfile(origine,'M2S_model_complet.osim');
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


