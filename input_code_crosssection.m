%% Your starter code where you input intensity image and skeleton into functions


skelfile = '/Users/noahschweitzer/Library/CloudStorage/OneDrive-UniversityofPittsburgh/TOF_humans/For_steve/skeletonTOF_human.nii'
imfile = '/Users/noahschweitzer/Library/CloudStorage/OneDrive-UniversityofPittsburgh/TOF_humans/For_steve/TOF_skullstripped_human.nii'
skel = niftiread(skelfile);
im = niftiread(imfile);
info = niftiinfo(imfile);
res = info.PixelDimensions
x = bwmorph3(skel,'branchpoints'); % matlab function to find branch points
y = skel-double(x);
CC = bwconncomp(y); %just connected components of branches
D = zeros(length(CC.PixelIdxList),1);
im=im/max(im(:)); % Very important for gaussian fit to work- you need to normalize image intensity.
tic %if you want to see how much time has passed since start of code


for j = 1:length(D),
	if length(CC.PixelIdxList{j})> 2 % Jiatai (Mike) did not do any pruning to skeleton, so there are several branches with 1-2 pixels
		[row,col,z] = ind2sub(size(im),CC.PixelIdxList{j});
		s = [row,col,z]; %inputing x,y,z coordinates into function
		D(j) = find_diam(s,im,res);
	else
		D(j)=NaN;
	end
	if mod(j,50)==0
		j
		toc
	end
end

% Initialize empty map
D_map = zeros(size(skel));

% Fill map with diameter values
for j = 1:length(D)
    if ~isnan(D(j))
        D_map(CC.PixelIdxList{j}) = D(j);
    end
end

niftiwrite(single(D_map), 'branch_diameter_map.nii');
