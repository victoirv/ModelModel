function ModelCompare(runname,runvars,xvar,fvar,IRParam1,IRParam2,basepath)
if(nargin<1 || isempty(runname))
    runname='Victoir_Veibell_092716_1'; 
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
if(nargin<5 || isempty(IRParam1))
    IRParam=[0 10 0]; %Default to 10 lags, no persist, no advance prediction
    %Make [0 1 1] for straight regression
end
if(nargin<6 || isempty(IRParam2))
    IRParam=[0 10 0]; %Default to 10 lags, no persist, no advance prediction
    %Make [0 1 1] for straight regression
end
if(nargin<7 || isempty(basepath))
    basepath='/media/D/CCMC';
    %basepath='/home/victoir/Work/Differences/data'; 
end


FigureBase=sprintf('%s_%s_%s_%s_%s',runname(end-7:end-2),runvars{xvar},sprintf('%d',fvar),sprintf('%d',IRParam1),sprintf('%d',IRParam2));
filenamecorr1=sprintf('data/%s/%s_%s_%s_corr.mat',runname,sprintf('%d',xvar),sprintf('%d',fvar),sprintf('%d',IRParam1));
filenamecorr2=sprintf('data/%s/%s_%s_%s_corr.mat',runname,sprintf('%d',xvar),sprintf('%d',fvar),sprintf('%d',IRParam2));

if(exist(filenamecorr1,'file')~=0)
    C1=load(filenamecorr1);
else
    fprintf('File %s does not exist\n',filenamecorr1);
    return;
end
if(exist(filenamecorr2,'file')~=0)
    C2=load(filenamecorr2);
else
    fprintf('File %s does not exist\n',filenamecorr2);
    return;
end

Diff=C1.corrmat-C2.corrmat;

x=C1.x;
y=C1.y;
z=C1.z;

figure;
POI=abs(y)<=1;
[Xg,Zg]=meshgrid(linspace(min(x(POI)),max(x(POI)),200),linspace(min(z(POI)),max(z(POI)),200));
vq=griddata(x(POI),z(POI),Diff(POI).^2,Xg,Zg);
surf(Xg,Zg,vq,'EdgeColor','none','LineStyle','none','FaceLighting','phong')
view(0,90)
xlabel('X (R_E)')
ylabel('Z (R_E)') %Y-axis in plot is Z-axis in space
colormap('parula')
ch=colorbar;
axis square
%set(ch,'ytick',[get(ch,'ytick') max(get(ch,'ylim'))])
caxis([0 1])
title(sprintf('Difference in correlations of %s on the Y=0 cutplane interpolated from grid points of Y<=1',runvars{xvar}))
print('-depsc2','-r200',sprintf('figures/Y0DiffCorrelations-Near_%s.eps',FigureBase))
print('-dpng','-r200',sprintf('figures/PNGs/Y0DiffCorrelations-Near_%s.png',FigureBase))