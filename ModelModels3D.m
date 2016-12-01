function ModelModels3D(modelnum,inputnum,IRParam)
if(nargin<1)
    modelnum=7; %Default to ux
end
if(nargin<2)
    inputnum=[8:15]; 
end
if(nargin<3 || isempty(IRParam))
    IRParam=[0 10 0]; %Default to 10 lags, no persist, no advance prediction
    %Make [0 1 1] for straight regression
end

%Define what run you want to use
runname='Victoir_Veibell_041316_1';
filenamecorr=sprintf('data/%s/DifferencesData_%s_all_3D_corr_%d_%s_%s.mat',runname,runname,modelnum,sprintf('%d',inputnum),sprintf('%d',IRParam));

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
            readmat(i,:,:)=sortrows(sortrows(sortrows(double(cell2mat(readdata)),1),2),3);

        end

        %{
        save(filename3,'readmat');
    end
        %}

    fprintf('Done reading data. Calculating correlations\n');

    warning('off','all') %lots of rank deficient warnings


    %Create correlations for each gridpoint
    corrmat=zeros(1,max(size(readmat)));
    corrmatv=zeros(1,max(size(readmat)));
    for i=1:max(size(readmat))
        [~,~,~,~,corr]=IR(readmat(:,i,modelnum),bininputs(:,inputnum),IRParam(1),IRParam(2),0,IRParam(3));
        corrmat(i)=corr;
        corrmatv(i)=readmat(1,i,modelnum);
    end
    X=readmat(1,:,1);
    Y=readmat(1,:,2);
    Z=readmat(1,:,3);
    save(filenamecorr,'X','Y','Z','corrmat'); %Save so analysis can be done later without recomputing

    fprintf('Done with correlations. Plotting\n');

else
    fprintf('Correlation data already exists; loading from file and moving to plots\n')
    load(filenamecorr)
end







%%%%%%%%%%%%%%%%%%%%%
%Plotting
%%%%%%%%%%%%%%%%%%%%%
POI=(abs(Y)<=0.2);
scatter3(X(POI),Y(POI),Z(POI),[],corrmat(POI));
view(-50,30)
xlabel('X (R_E)')
ylabel('Y (R_E)')
zlabel('Z (R_E)')
colorbar
print('-depsc2','-r200', 'NoteFigures/ClosestY0Points.eps')
print('-dpng','-r200', 'NoteFigures/ClosestY0Points.png')
%Verification
%scatter3(X(POI),Y(POI),Z(POI),[],corrmatv(POI));


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
isosurface(Xg,Yg,Zg,V,2)



[Xg,Zg]=meshgrid(linspace(min(X),max(X),200),linspace(min(Z),max(Z),200));
vq=griddata(X,Z,corrmat,Xg,Zg);
surf(Xg,Zg,vq,'EdgeColor','none','LineStyle','none','FaceLighting','phong')
view(0,90)
xlabel('X (R_E)')
zlabel('Z (R_E)')
title('Correlations on the Y=0 cutplane')
print('-dpng','-r200','NoteFigures/Y0Correlations.png')


POI=abs(Y)<=1;
[Xg,Zg]=meshgrid(linspace(min(X(POI)),max(X(POI)),200),linspace(min(Z(POI)),max(Z(POI)),200));
vq=griddata(X(POI),Z(POI),corrmat(POI),Xg,Zg);
surf(Xg,Zg,vq,'EdgeColor','none','LineStyle','none','FaceLighting','phong')
view(0,90)
xlabel('X (R_E)')
ylabel('Z (R_E)') %Y-axis in plot is Z-axis in space
colorbar
title('Correlations on the Y=0 cutplane interpolated from grid points of Y<=1')
print('-dpng','-r200','NoteFigures/Y0Correlations-Near.png')

%Gif Time
figure
giffilename = 'NoteFigures/AllYCutsScaled.gif';
k=1;
for i=unique(abs(Y))
    POI=(abs(Y)==i);
    scatter3(X(POI),Y(POI),Z(POI),[],corrmat(POI));
    view(-50,30)
    axis([min(X) max(X) min(Y) max(Y) min(Z) max(Z)])
    xlabel('X (R_E)')
    ylabel('Y (R_E)')
    zlabel('Z (R_E)')
    title(sprintf('Cutplane Y=%2.1f',i))
    colorbar

      drawnow
      frame = getframe(1);
      im = frame2im(frame);
      [imind,cm] = rgb2ind(im,256);
      if k == 1;
          imwrite(imind,cm,giffilename,'gif', 'Loopcount',inf);
      else
          imwrite(imind,cm,giffilename,'gif','WriteMode','append');
      end
      k=k+1;
end

