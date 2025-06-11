
%% Load diameter map
im2 = niftiread('/Users/noahschweitzer/Library/CloudStorage/OneDrive-UniversityofPittsburgh/TOF_humans/For_steve/branch_diameter_map.nii');
im2(im2 == 1) = 0; % remove value == 1 (if needed)

%% Get connected components (branches)
bwBranches = im2 > 0;
CC = bwconncomp(bwBranches);

%% Extract branch endpoints and diameter data
start_point = zeros(length(CC.PixelIdxList), 3);
end_point = zeros(length(CC.PixelIdxList), 3);
query_data = zeros(length(CC.PixelIdxList), 1);

for i = 1:length(CC.PixelIdxList)
    justLine = zeros(size(im2));
    justLine(CC.PixelIdxList{i}) = 1;
    
    ends = find(bwmorph3(justLine, 'endpoints'));
    if length(ends) >= 2
        [start_point(i,1), start_point(i,2), start_point(i,3)] = ind2sub(size(justLine), ends(1));
        [end_point(i,1), end_point(i,2), end_point(i,3)] = ind2sub(size(justLine), ends(2));
    else
        % If only one endpoint or none found → fallback to first voxel
        [start_point(i,1), start_point(i,2), start_point(i,3)] = ind2sub(size(justLine), CC.PixelIdxList{i}(1));
        [end_point(i,1), end_point(i,2), end_point(i,3)] = ind2sub(size(justLine), CC.PixelIdxList{i}(end));
    end
    
    % Diameter value for this branch (just read from first voxel)
    query_data(i) = im2(CC.PixelIdxList{i}(1));
end

%% Save intermediate data
save('for_pyvista_visualizing.mat', 'end_point', 'start_point', 'query_data', 'im2', 'bwBranches');

%% Load skeleton and process branchpoints
skel = niftiread('/Users/noahschweitzer/Library/CloudStorage/OneDrive-UniversityofPittsburgh/TOF_humans/For_steve/skeletonTOF_human.nii');
branchpointsImg = bwmorph3(skel, 'branchpoints');
CC_branchpoints = bwconncomp(branchpointsImg);

%% Remove large branchpoint clusters
f = cellfun(@length, CC_branchpoints.PixelIdxList);
finder = find(f > 7);
for i = 1:length(finder)
    branchpointsImg(CC_branchpoints.PixelIdxList{finder(i)}) = 0;
end

%% Extract border points (interaction between two sets of pixels)
finder_x = find(branchpointsImg); % branchpoints linear indices
finder_im2 = find(im2 > 0);       % voxels in branch diameter map

borders = [];
for i = 1:length(CC_branchpoints.PixelIdxList)
    members = ismember(finder_x, CC_branchpoints.PixelIdxList{i});
    if any(members)
        members2 = ismember(finder_im2, CC_branchpoints.PixelIdxList{i});
        if any(members2)
            borders = [borders; finder_x(members)];
        end
    end
end

%% Convert border linear indices to subscripts
branchpoints = zeros(length(borders), 3);
for i = 1:length(borders)
    [branchpoints(i,1), branchpoints(i,2), branchpoints(i,3)] = ind2sub(size(im2), borders(i));
end

%% Save updated branchpoints
save('for_pyvista_visualizing.mat', 'branchpoints', '-append');
