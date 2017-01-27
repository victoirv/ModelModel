function ModelByRows(runname,runvars,xvar,fvar,IRParam,basepath,normalize)
%function ModelByRows(runname,runvars,xvar,fvar,IRParam,basepath)
%Model a CCMC model using IR(), but do it piecewise by location to avoid
%overloading memory. Does 15,000 rows at a time (defined in 'chunksize')
%* Requires having first converted cdf files to mat files using CDFtoMAT
%* Assumes default solar wind input (15 vars defined in 'inputvars')
%* Defaults to using vars in 'runvars', should be whatever you kept in
%   CDFtoMAT
%* Can define 3 inputs to IR(): numxcoef, numfcoef, and advance
%** Advance parameter added to compare to R^2 models since default IR
%   behavior is to predict one step ahead (advance=0)
%* Base path for CDF files is definable. Base for solar wind is expected to
%   be in subdirectory of current folder/data/<model name>/SolarWind.mat

if(nargin<1 || isempty(runname))
    runname='Victoir_Veibell_092716_1'; %Default to ux
end
if(nargin<2 || isempty(runvars))
    runvars={'x','y','z','ux','uy','uz','bx','by','bz','jx','jy','jz','rho','p'};
end
if(nargin<3 || isempty(xvar))
    xvar=9; %Default to bz
end
if(nargin<4 || isempty(fvar))
    fvar=[8:15]; %Default to everything
end
if(nargin<5 || isempty(IRParam))
    IRParam=[0 10 0]; %Default to 10 lags, no persist, no advance prediction
    %Make [0 1 1] for straight regression
end
if(nargin<6 || isempty(basepath))
    basepath='/media/D/CCMC';
    %basepath='/home/victoir/Work/Differences/data'; 
end
if(nargin<7 || isempty(normalize))
    normalize=0;
end

filename=sprintf('data/%s/SolarWindData.mat',runname);

if(exist(filename,'file'))
    load(filename)
else
    %Variable names for model input data (solar wind)
    inputvars={'Year','Month','Day','Hour','Min','Sec','Msec','Bx[nT]','By[nT]','Bz[nT]','Vx[km/s]','Vy[km/s]','Vz[km/s]','N[cm^(-3)]','T[Kelvin]','RhoVx^2','VxBs'};
    
    %Read in solar wind data
    inputs=dlmread(sprintf('data/%s/%s_IMF.txt',runname,runname));
    
    %Add extra variables. Easier to do here than interpreting some function input as
    %a mathetmatical expression on the matrix 
    inputs(:,end+1)=inputs(:,14).*(inputs(:,11).^2); %rho*vx^2
    inputs(:,end+1)=inputs(:,11).*(inputs(:,10)-abs(inputs(:,10)))./2; %VxBs
    
    
    save(filename,'inputs','inputvars');
end


basedir=sprintf('%s/%s/GM_CDF/',basepath,runname);
files=dir(sprintf('%s/*%s.mat',basedir,strjoin(runvars,'')));
FigureBase=sprintf('%s_%s_%s_%s',runname(end-7:end-2),runvars{xvar},sprintf('%d',fvar),sprintf('%d',IRParam));

filenamecorr=sprintf('data/%s/%s_%s_%s',runname,sprintf('%d',xvar),sprintf('%d',fvar),sprintf('%d',IRParam));

if(normalize)
    FigureBase=sprintf('%s_norm',FigureBase);
    filenamecorr=sprintf('%s_norm',filenamecorr);
end


%Because the model will output all solar wind conditions, but only the first subset of model run data once you hit a file size limit
nfiles=length(files);
if((2*nfiles)<length(inputs)) %If there are more than twice as many solar wind inputs as files
    binsize=round(length(inputs)/nfiles);
    fprintf('Looks like file and solar wind cadence is different. Binning solar wind with a bin size of %d.\n',binsize);
    for i=1:(nfiles-1)
        bininputs(i,:)=median(inputs((i-1)*binsize+1:i*binsize,:));
    end
    bininputs(nfiles,:)=median(inputs((nfiles-1)*binsize+1:end,:),1);
    inputs=bininputs;
else
    inputs=inputs(1:length(files),:);
end



x=zeros(length(files),1);
chunksize=14000;

currentfile=sprintf('%s/%s',basedir,files(1).name);
matObj=matfile(currentfile);
N = max(size(matObj,'readdata'));
NVars = length(matObj.keepvars);


RandTest=0;
if(RandTest==1)
   inputs(:,fvar)=rand(size(inputs(:,fvar)));
   FigureBase=sprintf('%s_RandVerify',FigureBase);
   filenamecorr=sprintf('%s_RandVerify',filenamecorr);
end

x=double(matObj.readdata(:,1));
y=double(matObj.readdata(:,2));
z=double(matObj.readdata(:,3));

corrmat=zeros(length(x),1);
mostsig=corrmat;
mostsig2=corrmat;
mostsigr=corrmat;

normalizedInput=mean(inputs(:,fvar));

%Finalize filenamecorr
filenamecorr=sprintf('%s_corr.mat',filenamecorr);

if(~exist(filenamecorr,'file'))
    startpoint=1;
    endpoint=startpoint+chunksize-1;
    data=zeros(length(files),chunksize,NVars);
else
    load(filenamecorr)
    startpoint=find(corrmat==-1,1);
    if(~isempty(startpoint))
        fprintf('File already started. Skipping to index %d\n',startpoint);
        if(startpoint+chunksize<=N)
            endpoint=startpoint+chunksize;
        else
            endpoint=N;
        end
        data=zeros(length(files),endpoint-startpoint+1,NVars);
        
    else
        fprintf('Correlations already complete. To regenerate, delete the file. Moving on to plotting\n')
        startpoint=-1;
    end
    
end

warning('off','all')
if(startpoint>0)
    while(startpoint>0)
        for i=1:length(files)
            currentfile=sprintf('%s/%s',basedir,files(i).name);
            matObj=matfile(currentfile);
            %fprintf('Reading %s\n',currentfile);
            %format is data(time,space,var)
            data(i,:,:)=matObj.readdata(startpoint:endpoint,:);
        end
        fprintf('Correlating elements %d - %d\n',startpoint,endpoint-1);
        for j=1:(endpoint-startpoint)
            try
            if(normalize)
                %Normalize/standardize: (y-ymean)/ysigma, same for x
                Finput=bsxfun(@rdivide,bsxfun(@minus, inputs(:,fvar), mean(inputs(:,fvar))),std(inputs(:,fvar)));
                Xinput=bsxfun(@rdivide,bsxfun(@minus, data(:,j,xvar), mean(data(:,j,xvar))),std(data(:,j,xvar)));
                
                %If a point has no change in value, zero out results
                %instead of calling IR()
                if(sum(~isnan(Xinput))>0)
                 [~,cb,~,~,corr]=IR(Xinput,Finput,IRParam(1),IRParam(2),0,IRParam(3));
                else
                    corr=0;
                    cb=cb.*0; %Assuming this happens in the middle of a run, not the first time
                end
            else
                [~,cb,~,~,corr]=IR(data(:,j,xvar),inputs(:,fvar),IRParam(1),IRParam(2),0,IRParam(3));
            end
            catch
                breakpoint=1;
            end
            corrmat(startpoint+j-1)=corr;
            
            [~,mostsig(startpoint+j-1)]=max(cb);
            [~,mostsig2(startpoint+j-1)]=max(cb'./normalizedInput);
            rs=1:length(fvar);
            for k=1:length(fvar)
                if(normalize)
                    if(sum(~isnan(Xinput))>0)
                        r2=regstats(Xinput,bsxfun(@rdivide,bsxfun(@minus, inputs(:,fvar(k)), mean(inputs(:,fvar(k)))),std(inputs(:,fvar(k)))),'linear','rsquare');
                    else
                        r2.rsquare=0;
                    end
                else
                    r2=regstats(data(:,j,xvar),inputs(:,fvar(k)),'linear','rsquare');
                end
                rs(k)=r2.rsquare;
            end
            [~,maxi]=max(rs);
            mostsigr(startpoint+j-1)=maxi;
        end
        %Write results so far to file. Doesn't seem to like vector addressing
        %corrObj.corrmat(startpoint:endpoint)=corrmat(startpoint:endpoint);

        save(filenamecorr,'x','y','z','corrmat','mostsig','mostsig2','mostsigr','-v7.3');
        if(startpoint+chunksize>N)
            startpoint=0;
        elseif(endpoint+chunksize>N)
            endpoint=N;
            startpoint=startpoint+chunksize-1;
            data=zeros(length(files),endpoint-startpoint+1,NVars);
        else
            startpoint=startpoint+chunksize-1;
            endpoint=startpoint+chunksize-1;
        end
    end
    save(filenamecorr,'x','y','z','corrmat','mostsig','mostsig2','mostsigr','-v7.3');
end

figure;
POI=abs(y)<=1;
[Xg,Zg]=meshgrid(linspace(min(x(POI)),max(x(POI)),200),linspace(min(z(POI)),max(z(POI)),200));
vq=griddata(x(POI),z(POI),corrmat(POI).^2,Xg,Zg);
surf(Xg,Zg,vq,'EdgeColor','none','LineStyle','none','FaceLighting','phong')
view(0,90)
xlabel('X (R_E)')
ylabel('Z (R_E)') %Y-axis in plot is Z-axis in space
colormap(parula(20))
ch=colorbar;
axis square
%set(ch,'ytick',[get(ch,'ytick') max(get(ch,'ylim'))])
caxis([0 1])
title(sprintf('Correlations of %s on the Y=0 cutplane interpolated from grid points of Y<=1',runvars{xvar}))
print('-depsc2','-r200',sprintf('figures/Y0Correlations-Near_%s.eps',FigureBase))
print('-dpng','-r200',sprintf('figures/PNGs/Y0Correlations-Near_%s.png',FigureBase))

figure;
POI=abs(y)<=1;
[Xg,Zg]=meshgrid(linspace(min(x(POI)),max(x(POI)),200),linspace(min(z(POI)),max(z(POI)),200));
vq=griddata(x(POI),z(POI),mostsig(POI),Xg,Zg);
surf(Xg,Zg,vq,'EdgeColor','none','LineStyle','none','FaceLighting','phong')
view(0,90)
xlabel('X (R_E)')
ylabel('Z (R_E)') %Y-axis in plot is Z-axis in space
colormap(parula(length(fvar)))
ch=colorbar;
caxis([0 length(fvar)+1])
colorbar('YTick',0:length(fvar)+1,'YTickLabel',[' ' inputvars(fvar) ' '])
axis square
%set(ch,'ytick',[get(ch,'ytick') max(get(ch,'ylim'))])
%caxis([0 1])
title(sprintf('Most Significant variable per pixel on model of %s ',runvars{xvar}))
print('-depsc2','-r200',sprintf('figures/Y0MostSig-Near_%s.eps',FigureBase))
print('-dpng','-r200',sprintf('figures/PNGs/Y0MostSig-Near_%s.png',FigureBase))

figure;
POI=abs(y)<=1;
[Xg,Zg]=meshgrid(linspace(min(x(POI)),max(x(POI)),200),linspace(min(z(POI)),max(z(POI)),200));
vq=griddata(x(POI),z(POI),mostsigr(POI),Xg,Zg);
surf(Xg,Zg,vq,'EdgeColor','none','LineStyle','none','FaceLighting','phong')
view(0,90)
xlabel('X (R_E)')
ylabel('Z (R_E)') %Y-axis in plot is Z-axis in space
colormap(parula(length(fvar)))
ch=colorbar;
caxis([0 length(fvar)+1])
colorbar('YTick',0:length(fvar)+1,'YTickLabel',[' ' inputvars(fvar) ' '])
axis square
%set(ch,'ytick',[get(ch,'ytick') max(get(ch,'ylim'))])
%caxis([0 1])
title(sprintf('Most Significant variable per pixel on model of %s ',runvars{xvar}))
print('-depsc2','-r200',sprintf('figures/Y0MostSigr-Near_%s.eps',FigureBase))
print('-dpng','-r200',sprintf('figures/PNGs/Y0MostSigr-Near_%s.png',FigureBase))

figure;
POI=abs(y)<=1;
[Xg,Zg]=meshgrid(linspace(min(x(POI)),max(x(POI)),200),linspace(min(z(POI)),max(z(POI)),200));
vq=griddata(x(POI),z(POI),mostsig2(POI),Xg,Zg);
surf(Xg,Zg,vq,'EdgeColor','none','LineStyle','none','FaceLighting','phong')
view(0,90)
xlabel('X (R_E)')
ylabel('Z (R_E)') %Y-axis in plot is Z-axis in space
colormap(parula(length(fvar)))
ch=colorbar;
caxis([0 length(fvar)+1])
colorbar('YTick',0:length(fvar)+1,'YTickLabel',[' ' inputvars(fvar) ' '])
axis square
%set(ch,'ytick',[get(ch,'ytick') max(get(ch,'ylim'))])
%caxis([0 1])
title(sprintf('Most Significant variable per pixel on model of %s ',runvars{xvar}))
print('-depsc2','-r200',sprintf('figures/Y0MostSig2-Near_%s.eps',FigureBase))
print('-dpng','-r200',sprintf('figures/PNGs/Y0MostSig2-Near_%s.png',FigureBase))


figure;
POI=abs(x)<=1;
[Yg,Zg]=meshgrid(linspace(min(y(POI)),max(y(POI)),200),linspace(min(z(POI)),max(z(POI)),200));
vq=griddata(y(POI),z(POI),corrmat(POI),Yg,Zg);
surf(Yg,Zg,vq,'EdgeColor','none','LineStyle','none','FaceLighting','phong')
view(0,90)
xlabel('Y (R_E)')
ylabel('Z (R_E)') %Y-axis in plot is Z-axis in space
colormap(parula(20))
ch=colorbar;
axis square
%set(ch,'ytick',[get(ch,'ytick') max(get(ch,'ylim'))])
caxis([0 1])
title(sprintf('Correlations of %s on the X=0 cutplane interpolated from grid points of X<=1',runvars{xvar}))
print('-depsc2','-r200',sprintf('figures/X0Correlations-Near_%s.eps',FigureBase))
print('-dpng','-r200',sprintf('figures/PNGs/X0Correlations-Near_%s.png',FigureBase))

figure;
POI=abs(z)<=1;
[Xg,Yg]=meshgrid(linspace(min(x(POI)),max(x(POI)),200),linspace(min(y(POI)),max(y(POI)),200));
vq=griddata(x(POI),y(POI),corrmat(POI),Xg,Yg);
surf(Xg,Yg,vq,'EdgeColor','none','LineStyle','none','FaceLighting','phong')
view(0,90)
xlabel('X (R_E)')
ylabel('Y (R_E)') %Y-axis in plot is Z-axis in space
colormap(parula(20))
ch=colorbar;
axis square
%set(ch,'ytick',[get(ch,'ytick') max(get(ch,'ylim'))])
caxis([0 1])
title(sprintf('Correlations of %s on the Z=0 cutplane interpolated from grid points of Z<=1',runvars{xvar}))
print('-depsc2','-r200',sprintf('figures/Z0Correlations-Near_%s.eps',FigureBase))
print('-dpng','-r200',sprintf('figures/PNGs/Z0Correlations-Near_%s.png',FigureBase))