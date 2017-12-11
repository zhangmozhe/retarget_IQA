function Index = find_index(source_names, image_name)
IndexC = strfind(source_names, image_name);
Index = find(not(cellfun('isempty', IndexC)));