function mD = find_diam(s,ds,res)

res1 = res(1); res2 = res(2); res3 = res(3);
SL = zeros(25);

D = zeros(length(s)-1,1);
R = zeros(length(s)-1,1);
sd = [smooth(s(:,1)), smooth(s(:,2)), smooth(s(:,3))];

for i = 1:size(s,1)-1 % change "for" to "parfor"

   
   
   p1 = s(i,1);
   p2 = s(i,2);
   p3 = s(i,3);

    n1 = sd(i+1,1)-sd(i,1);
    n2 = sd(i+1,2)-sd(i,2);
    n3 = sd(i+1,3)-sd(i,3);

    [slice, sliceInd, subX, subY, subZ, hspVecXvec]  = extralice(ds,p1,p2,p3,n1,n2,n3,12);
    slice(isnan(slice))=-1; 
    slm = slice(slice>=0);
    ms = max(slm(:));
    if isempty(ms) ==1 
        ms = 1;
    end
    slice = slice/ms;
    slice(slice <0)= 0; 

%     imagesc(imadjust(slice))
%    colormap(jet)
%    
%     title(num2str(i))
%     pause(0.5)
%     

   
    SL = SL + slice;
    
    sl = mean(slice(12:14,:),1);
    if sum(isnan(sl(:))) > 5
        continue
    else
        sl = fillmissing(sl, 'nearest');
    end
    sl = sl-min(sl);
    
    %% trying to adjust for edge effects
    newind = sliceInd(13,:);
    x = 1:25;
    if find(sl==max(sl)) <= 2
    	x = 3:length(sl);
    	newind = newind(3:length(sl));
    	sl = sl(3:length(sl));
    elseif find(sl==max(sl)) >= length(sl)-1
    	x = 1:length(sl)-2;
    	newind = newind(1:length(sl)-2);
    	sl = sl(1:length(sl)-2);
    end
    
    [gaussfit, gof] = fit(x',sl','gauss1', 'Lower',[0,2,1],'Upper',[1,23,8],'StartPoint',[0.8 13 4]);
    pm = find(sl == max(sl(:)));
    pm = pm(1);
    [~,b1] = min(abs(sl(1:pm)-max(sl)/2));
    [~,b2] = min(abs(sl(pm:end)-max(sl)/2));
    b2 = b2(1)+pm-1;
    fwhm_pixels = abs(b1(1)-b2);
    
    %account for anisotropy
    [r1,r2,r3]=ind2sub(size(ds),newind(b1(1)));
    [r11,r22,r33]=ind2sub(size(ds),newind(b2));
    gh = zeros(2,3);
    gh(1,1) = r1;gh(1,2)=r2;gh(1,3)=r3;
    gh(2,1) = r11;gh(2,2)=r22;gh(2,3)=r33;
    fwhm = pdist(gh,'seuclidean',[1/res1,1/res2,1/res3]);
    %fwhm = 2*sqrt(log(2))*gaussfit.c1*res1;
    
    D(i) = fwhm;
    R(i) = gof.rsquare;
    %itt = itt + 1;
end
SL = SL/max(SL(:));
mD = mean(D(R>0.6)); %trying to be more generous
end
