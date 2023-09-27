% Charger la bibliothèque OpenSim
import org.opensim.modeling.*;

destination = '/Users/mathieubourgeois/Desktop/Traitement/';

%genericSetupForScale = 'Scale_Settings.xml';
%genericSetupPathScale =fullfile(destination);


IndivForScale = dir(fullfile(destination, 'Participant*'));
nIndiv = size(IndivForScale);

for Indiv = 1:nIndiv

    genericSetupForScale = 'Scale_Settings.xml';
    genericSetupPathScale =fullfile(destination);

    nameIndiv = IndivForScale(Indiv).name;

    fullpathNameIndiv = fullfile(destination, nameIndiv);
    %disp(fullpathNameIndiv)
    cd(nameIndiv);

    StaticIndiv = dir(fullfile(fullpathNameIndiv, '*.trc'));
    nameStatic = StaticIndiv().name;
    fullpathStatic = fullfile(destination,nameIndiv,nameStatic);

    cd(destination);

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

for Indiv = 1:nIndiv
destinationScale = strcat(destination, 'Participant1/');

nameIndiv = IndivForScale(Indiv).name;

fullpathNameIndiv = fullfile(destination, nameIndiv);
cd(nameIndiv);
ConstructorName = ['Scale_' nameIndiv '.xml'];
% Instancier l'outil d'ajustement de l'échelle
scaleTool = ScaleTool(ConstructorName);
cd(destination)

% Changer le modèle si nécessaire
scaleTool.getGenericModelMaker.setModelFileName('M2S_model_complet.osim');

% Exécuter l'outil d'ajustement de l'échelle
scaleTool.run()

end



