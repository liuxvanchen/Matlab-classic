% Specify the path to your HDF4 file
file_path = 'E:\test\GLASS01B02.V40.A1982001.2019353.hdf';

% Get information about the HDF4 file
info = hdfinfo(file_path);

% Display dataset names
dataset_names = {info.Vdata.Name};
disp('Data set names:');
disp(dataset_names);

% Access and display units of each Vdata
for i = 1:numel(info.Vdata)
    vdata_name = info.Vdata(i).Name;
    vdata_info = info.Vdata(i);
    
    % Check if there are any attributes
    if isfield(vdata_info, 'Attributes')
        attributes = vdata_info.Attributes;
        
        % Look for 'units' attribute
        units_value = 'Not available'; % default value
        for j = 1:numel(attributes)
            if strcmp(attributes(j).Name, 'units')
                units_value = attributes(j).Value;
                break;
            end
        end
    else
        units_value = 'Not available';
    end
    
    disp(['Dataset: ', vdata_name]);
    disp(['Units: ', units_value]);
end
