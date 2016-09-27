function ModelModels3D(modelnum,inputnum)
if(nargin<1)
    modelnum=7; %Default to ux
end
if(nargin<2)
    inputnum=[8:15]; 
end

%Define what run you want to use
runname='Victoir_Veibell_041316_1';
filenamecorr=sprintf('data/%s/DifferencesData_%s_all_3D_corr_%d_%s.mat',runname,runname,modelnum,num2str(inputnum,'%d'));

%Test if correlation data already exists for this particular set of inputs
%and outputs (saves half an hour easily if so)
if(~exist(filenamecorr,'file'))

    fprintf('Reading in solar wind data\n');

    %Filename to save data to for easier/quicker future reading
    filename=sprintf('data/%s/DifferencesData_%s_3D.mat',runname,runname);

    if(exist(filename,'file'))
        load(filename)
    else
        %Find number of existing time steps, then read in the model data for each
        %step into one array
        [status,ncuts]=system(sprintf('ls -1 data/%s/data/cuts/ | wc -l',runname));
        ncuts=str2double(ncuts);

        %Variable names for model input data (solar wind)
        inputvars={'Year','Month','Day','Hour','Min','Sec','Msec','Bx[nT]','By[nT]','Bz[nT]','Vx[km/s]','Vy[km/s]','Vz[km/s]','N[cm^(-3)]','T[Kelvin]'};

        %Read in solar wind data
        inputs=dlmread(sprintf('data/%s/%s_IMF.txt',runname,runname));

        %Bin the input data to be on the same grid as the model data that came
        %from brian's code
        for i=1:(ncuts-1)
            bininputs(i,:)=median(inputs((i-1)*30+1:i*30,:));
        end
        bininputs(ncuts,:)=median(inputs((ncuts-1)*30+1:end,:));

        save(filename,'inputs','bininputs','inputvars');
    end

    fprintf('Reading in model data\n');

    %Default headers for model data
    dataheaders={'x','y','z','bx','by','bz','ux','rho'};

    %Find all CDF files for each timestep and read them in to one array
    basedir='/home/victoir/Work/Differences/data/Victoir_Veibell_041316_1/GM_CDF/';
    files=dir(sprintf('%s/*cdf',basedir));

    %{
    %Attempt to save giant file. Doesn't seem to work as is, possible memory
    %limitations
    filename3=sprintf('data/%s/DifferencesData_%s_all_3D.mat',runname,runname);
    if(exist(filename3,'file'))
        load(filename3)
    else
    %}

        %Pre-allocate readmat for speed
        info=cdfinfo(sprintf('%s/%s',basedir,files(1).name));
        presize=info.Variables{1,2};
        readmat=zeros(length(files),presize(1),length(dataheaders));

        for i=1:length(files)
            currentfile=files(i).name;
            readname=sprintf('%s/%s',basedir,currentfile);
            readdata=cdfread(readname,'Variables',dataheaders);
            readmat(i,:,:)=double(cell2mat(readdata));

        end

        %{
        save(filename3,'readmat');
    end
        %}

    fprintf('Done reading data. Calculating correlations\n');

    warning('off','all') %lots of rank deficient warnings


    %Create correlations for each gridpoint
    corrmat=zeros(1,max(size(readmat)));
    for i=1:max(size(readmat))
        [~,~,~,~,corr]=IR(readmat(:,i,modelnum),bininputs(:,inputnum),0,4);
        corrmat(i)=corr;
    end
    X=readmat(1,:,1);
    Y=readmat(1,:,2);
    Z=readmat(1,:,3);
    save(filenamecorr,'X','Y','Z','corrmat'); %Save so analysis can be done later without recomputing

    fprintf('Done with correlations. Plotting\n');

else
    fprintf('Correlation data already exists; loading from file and moving to plots')
    load(filenamecorr)
end

%%%%%%%%%%%%%%%%%%%%%
%Plotting
%%%%%%%%%%%%%%%%%%%%%
%Plot all data
scatter3(X,Y,Z,[],corrmat);
print('-depsc2','-r200', 'NoteFigures/CorrFullScatter3.eps')
close all;

%Plot only points with certain correlation
figure;
drawcorr=0.9;
drawwidth=0.01;
POI=((corrmat<(drawcorr+drawwidth))+(corrmat>(drawcorr-drawwidth)))>1;
scatter3(X(POI),Y(POI),Z(POI),[],corrmat(POI));
title(sprintf('Correlation values of %2.2f +- %2.2f',drawcorr,drawwidth))
print('-depsc2','-r200', 'NoteFigures/CorrPOIScatter3.eps')


figure;
r=sqrt(X.^2+Y.^2+Z.^2);
POI=((r<=3)+(r>=2.8))>1;
scatter3(X(POI),Y(POI),Z(POI),[],corrmat(POI));
title('Correlation values of Ionosphere')
print('-depsc2','-r200', 'NoteFigures/IonosphereScatter3.eps')
print('-dpng','-r200', 'NoteFigures/IonosphereScatter3.png')

%Continue using r for ionosphere and POI from previous figure
figure
tri=delaunay(X(POI),Y(POI),Z(POI));
subplot(1,2,1)
trisurf(tri,X(POI),Y(POI),Z(POI),corrmat(POI))
view(90,90)
lighting phong
shading interp
xlabel('X (R_E)')
ylabel('Y (R_E)')
zlabel('Z (R_E)')
subplot(1,2,2)
trisurf(tri,X(POI),Y(POI),Z(POI),corrmat(POI))
view(90,270)
lighting phong
shading interp
xlabel('X (R_E)')
ylabel('Y (R_E)')
zlabel('Z (R_E)')
colorbar EastOutside
print('-depsc2','-r200', 'NoteFigures/IonosphereSurf.eps')
print('-dpng','-r200', 'NoteFigures/IonosphereSurf.png')


figure;
subplot(1,2,1)
POI=((r<=3.2)+(r>=2.8)+(readmat(1,:,3)<0))>2;
scatter3(X(POI),Y(POI),Z(POI),[],corrmat(POI));
view(0,90)
xlabel('X (R_E)')
ylabel('Y (R_E)')
title('Z<0')

subplot(1,2,2)
POI=((r<=3.2)+(r>=2.8)+(readmat(1,:,3)>0))>2;
scatter3(X(POI),Y(POI),Z(POI),[],corrmat(POI));
view(0,90)
xlabel('X (R_E)')
ylabel('Y (R_E)')
title('Z>0')
print('-depsc2','-r200', 'NoteFigures/IonospherePolarCuts.eps')
print('-dpng','-r200', 'NoteFigures/IonospherePolarCuts.png')



figure; scatter(X(POI)./(1+Y(POI)),Y(POI)./(1+Z(POI)),[],corrmat(POI))
print('-dpng','-r200','NoteFigures/StereographicIonosphere.png')

%Plot a cutplane or correlations
POI=readmat(1,:,2)==0; %Where Y=0
scatter3(X(POI),Y(POI),Z(POI),[],corrmat(POI));
print('-depsc2','-r200', 'NoteFigures/CorrPOIScatter3.eps')



F=scatteredInterpolant(X',Y',Z',corrmat');

[Xg,Yg,Zg]=meshgrid(linspace(min(X),max(X),100),linspace(min(Y),max(Y),100),linspace(min(Z),max(Z),100));
V=F(Xg,Yg,Zg);


%%%%%%%%%%%%%%
%Stuff after here is just looking at one CDF file (one time step), not
%correlations. Kept mostly as sample algorithms



%Read in CDF and convert to workable matrix. Note, not all variables have
%the same amount of rows, but since we're selecting  ones that do we can
%convert straight to a matrix, and then to a double() for the sake of the
%following functions that require doubles.
test=cdfread('/home/victoir/Work/Differences/data/Victoir_Veibell_041316_1/GM_CDF/3d__var_1_e20100101-000000-000.out.cdf','Variables',{'x','y','z','bx','by','bz','rho'});
testmat=double(cell2mat(test));

%Interpolate onto a mesh grid.
F=scatteredInterpolant(double(testmat(:,1)),double(testmat(:,2)),double(testmat(:,3)),double(testmat(:,7)));
[X,Y,Z]=meshgrid(linspace(min(testmat(:,1)),max(testmat(:,1)),100),linspace(min(testmat(:,2)),max(testmat(:,2)),100),linspace(min(testmat(:,3)),max(testmat(:,3)),100));
V=F(double(X),double(Y),double(Z));
X=X(:);
Y=Y(:);
Z=Z(:);
V=V(:);
%Can attempt to plot all data, but plotting 1M points is a bit much
%scatter3(X(:),Y(:),Z(:),[],V(:))

%Only plotting points of interest at a certain contour. Un-hard-code this
%as threshold+-epsilon
POI=((V(:)<1.9)+(V(:)>1.8))>1;
scatter3(X(POI),Y(POI),Z(POI),[],V(POI),'.','LineWidth',0.1)
print('-depsc2','-r200', 'NoteFigures/InterpScatter3.eps')

%Testing non-interpolated grid
POI2=((testmat(:,7)<1.9)+(testmat(:,7)>1.8))>1;
scatter3(testmat(POI2,1),testmat(POI2,2),testmat(POI2,3),[],testmat(POI2,7),'.','LineWidth',0.1)
print('-depsc2','-r200', 'NoteFigures/OriginalScatter3.eps')


%Interpolated isosurface selects specific value and makes solid surface for
%it.
isosurface(X,Y,Z,V,2)

%First workings of an animation
for i=[100 10 5 2 1.8 1.5 1.3 1 0.5 0.1]
    close all; 
    isosurface(X,Y,Z,V,i); 
    pause(2);
end





