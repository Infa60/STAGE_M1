%Load OpenSim libs
import org.opensim.modeling.*


origine = '/Users/mathieubourgeois/Desktop/Analyse/C3DFiles';
destination = '/Users/mathieubourgeois/Desktop/Analyse';
destinationParent = fullfile(destination,'Traitement');


IndivForConvert = dir(fullfile(origine, 'Participant*'));
nIndiv = size(IndivForConvert);

for Indiv = 1:nIndiv

    nameIndiv = IndivForConvert(Indiv).name;
    cd(origine)
    cd(nameIndiv);
    destinationIndiv = fullfile(origine, nameIndiv);

    %Récupération du nombre de fichier à traiter dans Data
    trialsForConvert = dir(fullfile(destinationIndiv, '*.c3d'));
    nTrials = size(trialsForConvert);

    

    destinationTrc = fullfile(destinationParent,nameIndiv,'Data');

    

    for trial= 1:nTrials
        ToConvertFileName = trialsForConvert(trial).name;
        name = regexprep(ToConvertFileName,'.c3d','');
        %disp(ToConvertFileName)

        if startsWith(name, 'Static')
        % save location for static files
        destinationTrc = fullfile(destinationParent,nameIndiv);
        else

        % save location for non-static files
        destinationTrc = fullfile(destinationParent,nameIndiv,'Data');
        end

        if ~exist(destinationTrc, 'dir')
        mkdir(destinationTrc);
        end


        filename=ToConvertFileName;
        c3dpath = fullfile(destinationIndiv,filename);
        
        
        c3d = osimC3D(c3dpath,1);
           
        % Get some stats...
        % Get the number of marker trajectories
        nTrajectories = c3d.getNumTrajectories();
        % Get the marker data rate
        rMakers = c3d.getRate_marker();
        % Get the number of forces 
        nForces = c3d.getNumForces();
        % Get the force data rate
        rForces = c3d.getRate_force();
        
        % Get Start and end time
        t0 = c3d.getStartTime();
        tn = c3d.getEndTime();
        
        % Rotate the data 
        c3d.rotateData('y',90)
        c3d.rotateData('z',90)
        
        % Get the c3d in different forms
        % Get OpenSim tables
        markerTable = c3d.getTable_markers();
        forceTable = c3d.getTable_forces();
        % Get as Matlab Structures
        [markerStruct forceStruct] = c3d.getAsStructs();
        
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



        %%%
    end

    cd(origine)

end
