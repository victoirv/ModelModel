## History ##
* [December 9: Further Differences](#december-9-2016)
* [December 6: Model Differences](#december-6-2016)
* [December 1: Better Comparison](#december-1-2016)
* [November 15: Comparison](#november-15-2016)
* [November 8: Ten minute data](#november-8-2016)
* [October 26: One minute data](#october-26-2016)
* [October 17: 3D Correlation Plots](#october-17-2016)
* [September 27: Optimization](#september-27-2016)
* [September 5: Vx vs Vx](#september-5-2016)
* [September 1: Correlation plots?](#september-1-2016)
* [August 31: First 3D attempts](#august-31-2016)

### December 9, 2016 ###
Continuing that analysis, looking more specifically at differences between the 1-lag and 10-lag models:

Vx: 1-lag | 10-lag | Difference
:--:|:--:|:--:
![f](figures/PNGs/Y0Correlations-Near_6_1_fu_ux_89101112131415_011.png) | ![f](figures/PNGs/Y0Correlations-Near_6_1_fu_ux_89101112131415_0100.png) | ![f](figures/PNGs/Y0DiffCorrelations-Near_6_1_fu_ux_89101112131415_0100_011.png)

Bz: 1-lag | 10-lag | Difference
:--:|:--:|:--:
![f](figures/PNGs/Y0Correlations-Near_6_1_fu_bz_89101112131415_011.png) | ![f](figures/PNGs/Y0Correlations-Near_6_1_fu_bz_89101112131415_0100.png) | ![f](figures/PNGs/Y0DiffCorrelations-Near_6_1_fu_bz_89101112131415_0100_011.png#)

Rho: 1-lag | 10-lag | Difference
:--:|:--:|:--:
![f](figures/PNGs/Y0Correlations-Near_6_1_fu_rho_89101112131415_011.png) | ![f](figures/PNGs/Y0Correlations-Near_6_1_fu_rho_89101112131415_0100.png) | ![f](figures/PNGs/Y0DiffCorrelations-Near_6_1_fu_rho_89101112131415_0100_011.png#)

Vx from RhoVx^2: 1-lag | 10-lag | Difference
:--:|:--:|:--:
![f](figures/PNGs/Y0Correlations-Near_6_1_fu_ux_16_011.png) | ![f](figures/PNGs/Y0Correlations-Near_6_1_fu_ux_16_0100.png) | ![f](figures/PNGs/Y0DiffCorrelations-Near_6_1_fu_ux_16_0100_011.png#)

Vx from VxBs: 1-lag | 10-lag | Difference
:--:|:--:|:--:
![f](figures/PNGs/Y0Correlations-Near_6_1_fu_ux_17_011.png) | ![f](figures/PNGs/Y0Correlations-Near_6_1_fu_ux_17_0100.png) | ![f](figures/PNGs/Y0DiffCorrelations-Near_6_1_fu_ux_17_0100_011.png)

Vx from [RhoVx^2, VxBs]: 1-lag | 10-lag | Difference
:--:|:--:|:--:
![f](figures/PNGs/Y0Correlations-Near_6_1_fu_ux_1617_011.png) | ![f](figures/PNGs/Y0Correlations-Near_6_1_fu_ux_1617_0100.png) | ![f](figures/PNGs/Y0DiffCorrelations-Near_6_1_fu_ux_1617_0100_011.png)

This lack of correlation seems odd, but might be due to only using one input variable in the model (RhoVx^2 being treated as one variable). I'm going to start working on plots that show how much each input variable contributes to the model at each pixel to see if anything in particular shows up.

##### Verification attempts #####
Wanted to explore a couple of potential issues. First generated a model where solar wind was just random noise to see what kind of correlation the model would get from 7 random variables. Everything came up with correlation of almost 0 with no structure so no problem there. Next question was which variables contributed the most to any particular correlation. Three plots were created for a 1-lag model of Vx; one showing which had the largest coefficient at each location, one with the coefficient/(mean variable value) as an attempt at normalization, and another showing which variable had the highest R^2 value against the model at each location.

Significant inputs from coef | Significant inputs from coef/mean | Significant inputs from R^2
:--:|:--:|:--:
![f](figures/PNGs/Y0MostSig-Near_6_1_fu_ux_910111415_011.png) | ![f](figures/PNGs/Y0MostSig2-Near_6_1_fu_ux_910111415_011.png) | ![f](figures/PNGs/Y0MostSigr-Near_6_1_fu_ux_910111415_011.png)

These three methods come up with significantly different results. Other than Vx outside the magnetosphere and Bz close to earth, most of the magnetosphere shows a different largest R^2 variable than largest model coefficient variable, and the normalized version is different all over. The question is then which version most meaningfully depicts the impact of each input variable on the model. Individual tests of R^2 seem reasonable for a single lag linear model, but scaling to a full IR model could become computationally expensive. Using the model coefficients directly makes sense, but perhaps a better normalization method needs to be devised.



### December 6, 2016 ###
We wanted to compare how a single lag regression model compares to a ten-lag IR model. This involved generating the correlation matrix for both models, then making plots of the differences between the two. For example, using the first 30-minute cadence run:

Vx: 1-lag | 10-lag | Difference
:--:|:--:|:--:
![f](figures/PNGs/Y0Correlations-Near_041316_ux_89101112131415_011.png) | ![f](figures/PNGs/Y0Correlations-Near_041316_ux_89101112131415_0100.png) | ![f](figures/PNGs/Y0DiffCorrelations-Near_041316_ux_89101112131415_0100_011.png)

Or for Bz for the 10-minute cadence model:

Bz: 1-lag | 10-lag | Difference
:--:|:--:|:--:
![f](figures/PNGs/Y0Correlations-Near_6_1_fu_bz_89101112131415_011.png) | ![f](figures/PNGs/Y0Correlations-Near_6_1_fu_bz_89101112131415_0100.png) | ![f](figures/PNGs/Y0DiffCorrelations-Near_6_1_fu_bz_89101112131415_0100_011.png)

And then for the difference in one model (in this case the 10-lag model) comparing the difference in correlation between the 10-minute cadence data and the 30-minute cadence data:

Bz: 10-minute | 30-minute | Difference
:--:|:--:|:--:
![f](figures/PNGs/Y0Correlations-Near_6_1_fu_bz_89101112131415_0100.png) | ![f](figures/PNGs/Y0Correlations-Near_041316_bz_89101112131415_0100.png) | ![f](NoteFigures/Y0DiffCorrelations-Near_bz.png)

The question here is whether the difference in correlations arises due to differences in the actual model, differences in the span of data (the 10-minute cadence model covers 7 days of data while the 30-minute model covers 1 day), or some other statistical discrepancy. These things will be investigated, and further plots will be generated.

### December 1, 2016 ###
It appears that using older code, along with accounting for the fact that Vincent is doing `r^2` and `corrcoef` just does `r` is enough to account for the differences:

Vx-Mine | Vx-His
:--:|:--:
![f](figures/PNGs/Y0Correlations-Brian-Near_041316_011.png) | ![f](figures/PNGs/vcaetto/linear_ux.png)

Issue was that newer code was expecting solar wind cadence to be the same as cdf-file cadence. With some new code in there to automatically adapt it if they're significantly different (bin by increments of round(nSolarWind/nFiles)), I get good results again:

Vx-Old | Vx-New
:--:|:--:
![f](figures/PNGs/Y0Correlations-Brian-Near_041316_011.png) | ![f](figures/PNGs/Y0Correlations-Near_041316_ux_89101112131415_011.png)

And then just to make sure the comparisons are good across variables:

Bz-Mine | Bz-His
:--:|:--:
![f](figures/PNGs/Y0Correlations-Near_041316_bz_89101112131415_011.png) | ![f](figures/PNGs/vcaetto/linear_bz.png)
P-Mine | P-His
![f](figures/PNGs/Y0Correlations-Near_041316_p_89101112131415_011.png) | ![f](figures/PNGs/vcaetto/linear_p.png)
Rho-Mine | Rho-His
![f](figures/PNGs/Y0Correlations-Near_041316_rho_89101112131415_011.png) | ![f](figures/PNGs/vcaetto/linear_rho.png)


### November 15, 2016 ###
Comparing results of my linear regression code to that of vcaetto's linear regression results finds similar results, but with noticeable differences, mostly in terms of correlation values rather than structure. Whether these are due to the difference in interpolation (I use an average of the nearest slices to Y=0 direct from the cdf files, he uses Brian's code to interpolate an average Y=0 plane from the entire grid, as I understand it) or due to something else remains to be tested:

Vx-Mine | Vx-His
:--:|:--:
![f](figures/PNGs/Y0Correlations-Near_092716_ux_8 9101112131415_011.png) | ![f](figures/PNGs/vcaetto/linear_ux.png)
Vy-Mine | Vy-His
![f](figures/PNGs/Y0Correlations-Near_092716_uy_8 9101112131415_011.png) | ![f](figures/PNGs/vcaetto/linear_uy.png)
Vz-Mine | Vz-His
![f](figures/PNGs/Y0Correlations-Near_092716_uz_8 9101112131415_011.png) | ![f](figures/PNGs/vcaetto/linear_uz.png)
Bx-Mine | Bx-His
![f](figures/PNGs/Y0Correlations-Near_092716_bx_8 9101112131415_011.png) | ![f](figures/PNGs/vcaetto/linear_bx.png)
By-Mine | By-His
![f](figures/PNGs/Y0Correlations-Near_092716_by_8 9101112131415_011.png) | ![f](figures/PNGs/vcaetto/linear_by.png)
Bz-Mine | Bz-His
![f](figures/PNGs/Y0Correlations-Near_092716_bz_8 9101112131415_011.png) | ![f](figures/PNGs/vcaetto/linear_bz.png)
P-Mine | P-His
![f](figures/PNGs/Y0Correlations-Near_092716_p_8 9101112131415_011.png) | ![f](figures/PNGs/vcaetto/linear_p.png)
Rho-Mine | Rho-His
![f](figures/PNGs/Y0Correlations-Near_092716_rho_8 9101112131415_011.png) | ![f](figures/PNGs/vcaetto/linear_rho.png)

Also took a shot at making X=0 and Z=0 cutplanes to see if anything interesting popped up:

Vx: X=0 | Y=0 | Z=0
:--:|:--:|:--:
![f](figures/PNGs/X0Correlations-Near_092716_ux_8 9101112131415_011.png) | ![f](figures/PNGs/Y0Correlations-Near_092716_ux_8 9101112131415_011.png) | ![f](figures/PNGs/Z0Correlations-Near_092716_ux_8 9101112131415_011.png)

Bz: X=0 | Y=0 | Z=0
:--:|:--:|:--:
![f](figures/PNGs/X0Correlations-Near_092716_bz_8 9101112131415_011.png) | ![f](figures/PNGs/Y0Correlations-Near_092716_bz_8 9101112131415_011.png) | ![f](figures/PNGs/Z0Correlations-Near_092716_bz_8 9101112131415_011.png)

It nicely illuminates the structure of the bow shock, and then the magnetosphere. It's surprising that the correlations aren't higher between solar wind inputs and the region of space outside the magnetosphere, ~~but perhaps the grid density is higher at the magnetosphere boundary and as such has more innate weight in training the regression model. To attempt to look at this, I made a histogram of the correlation value of all points with |Y|<1 with the expectation that, from just looking at the graph, if points were evenly distributed you'd have an average correlation of about 0.7, maybe less.~~

Vx | Hist | Hist-3D
:--:|:--:|:--:
![f](figures/PNGs/Y0Correlations-Near_092716_ux_8 9101112131415_011.png) | ![f](NoteFigures/Y0Correlations-Hist.png) | ![f](NoteFigures/Y0Correlations-Hist3.png)

~~This suggests that the regions with higher correlation also have a greater density of grid points, and that perhaps the model is biased by this. That said, if those high-density regions are what people using the CCMC model are most interested in, then this bias in my model isn't really an issue.~~

**Okay, wasn't thinking particularly well about this. IR models are entirely self-contained within a grid point and only concerned with changes in time, so the only way grid density would be an influence is if the CCMC model accounts for input solar wind conditions at all grid points to some degree and then propagation leads to higher density regions being more correlated with solar wind conditions.**

### November 8, 2016 ###
Looking at the 8 days of 10-minute cadence data with a 10-lag IR model shows relatively high correlations:

Vx | Bz
:--:|:--:
![f](figures/PNGs/Y0Correlations-Near_6_1_fu_ux_8 9101112131415_010 0.png) | ![f](figures/PNGs/Y0Correlations-Near_6_1_fu_bz_8 9101112131415_010 0.png)

Rho | P
:--:|:--:
![f](figures/PNGs/Y0Correlations-Near_6_1_fu_rho_8 9101112131415_010 0.png) | ![f](figures/PNGs/Y0Correlations-Near_6_1_fu_p_8 9101112131415_010 0.png)

*Note for future reference with this model: The run was originally started with 1-minute cadence, then switched over because it caused issues on the CCMC side. They ended up providing roughly two days of 1-minute data followed by six days of 10-minute data, but the solar wind data was 1-minute the whole way through. Both had to be organized onto the same timescale, and I did that by keeping every cdf file and solar wind entry with a minute ending in 0 (e.g. 1:30, 1:40, 1:50, 2:00). There were also two cdf files (at least. Two with minutes ending in 0) occurring on the same time step, but different endings (e.g. 3d\__var_1_e20100101-065000-304.out and 3d__var_1_e20100101-065000-391.out), so not knowing the significance I just kept the lower numbered version.*

### October 26, 2016 ###
Looking at the results for the CCMC run with one-minute cadence produces the following plots.

#### Regression ####
Bx | By | Bz
:--:|:--:|:--:
![f](figures/PNGs/Y0Correlations-Near_092716_bx_8 9101112131415_011.png) | ![f](figures/PNGs/Y0Correlations-Near_092716_by_8 9101112131415_011.png) | ![f](figures/PNGs/Y0Correlations-Near_092716_bz_8 9101112131415_011.png)


Vx | Vy | Vz
:--:|:--:|:--:
![f](figures/PNGs/Y0Correlations-Near_092716_ux_8 9101112131415_011.png) | ![f](figures/PNGs/Y0Correlations-Near_092716_uy_8 9101112131415_011.png) | ![f](figures/PNGs/Y0Correlations-Near_092716_uz_8 9101112131415_011.png)

Jx | Jy | Jz
:--:|:--:|:--:
![f](figures/PNGs/Y0Correlations-Near_092716_jx_8 9101112131415_011.png) | ![f](figures/PNGs/Y0Correlations-Near_092716_jy_8 9101112131415_011.png) | ![f](figures/PNGs/Y0Correlations-Near_092716_jz_8 9101112131415_011.png)

P | Rho
:--:|:--:
![f](figures/PNGs/Y0Correlations-Near_092716_p_8 9101112131415_011.png) | ![f](figures/PNGs/Y0Correlations-Near_092716_rho_8 9101112131415_011.png)

#### 10 1-minute lags ####
*Note that this is **Vx** and **By, Bz**, just in one row to minimize giant figures*

Vx | By | Bz
:--:|:--:|:--:
![vx](figures/PNGs/Y0Correlations-Near_092716_ux_8 9101112131415.png) | ![vx](figures/PNGs/Y0Correlations-Near_092716_by_8 9101112131415.png) | ![vx](figures/PNGs/Y0Correlations-Near_092716_bz_8 9101112131415.png)

Jx | Jy | Jz
:--:|:--:|:--:
![vx](figures/PNGs/Y0Correlations-Near_092716_jx_8 9101112131415.png) | ![vx](figures/PNGs/Y0Correlations-Near_092716_jy_8 9101112131415.png) | ![vx](figures/PNGs/Y0Correlations-Near_092716_jz_8 9101112131415.png)

Rho:
![vx](figures/PNGs/Y0Correlations-Near_092716_rho_8 9101112131415.png)


I'm still generating more plots, but this requires regenerating all the mat files (and finding more ways to free up hard drive space and deal with corrupt mat files from when it runs out), and now generating a correlation matrix for each variable, which takes ~1 hour each for the full solar wind input model. Will update here when they  complete.

### October 17, 2016 ###
Turns out the cdf files for each timestep in a run don't keep consistent ordering of rows. Sorting each cdf file by X, Y, and Z results in a matrix that can be correlated row-wise through time. The following figures use a 10-lag (5 hour) impulse response model of V_x given all solar wind B components, V components, N, and T. Since there are no grid points at Y=0, here are the closest values at Y=0.125:
![vx](NoteFigures/ClosestY0Points.png)

Or a plot taking all points and interpolating/projecting them onto the Y=0 cutplane:
![vx](NoteFigures/Y0Correlations.png)

I'm still investigating whether these odd grid patterns are from the interpolation or if there is still some issue with rows. The few files I checked all had the same grid points after sorting, but perhaps this changes somewhere through the run.

If I only use the points with values of abs(Y)<=1 for the interpolation, I get something more sensible:
![vx](NoteFigures/Y0Correlations-Near.png)

I've also made gifs to visualize the entire 3D space. The first one plotting each unique Y cutplane with its own scale so you can see the structure, and the second plotting them with set axes to see how the grid changes size and shape at each step in Y value.

![vx](NoteFigures/AllYCuts.gif)
![vx](NoteFigures/AllYCutsScaled.gif)

#### Regression ####

Doing this same thing for a linear regression model (x_t=a*f_t+c where f is all solar wind inputs) gets an interpolated Y=0 cutplane like this:
 ![vx](NoteFigures/Y0Correlations-Regress.png)

 Or only interpolating from grid points of Y<=1:
 ![vx](NoteFigures/Y0Correlations-Near-Regress.png)


 and the actual correlations of nearest points:

 ![vx](NoteFigures/ClosestY0Points-Regress.png)

### September 27, 2016 ###
Looking into [large file handling](http://www.matlabtips.com/how-to-store-large-datasets/) and [volume visualization](https://www.mathworks.com/help/matlab/volume-visualization.html)

Code now saves X,Y,Z, and correlations for each point based on what model inputs and outputs you select, saving 30+ minutes of reading and calculations on subsequent runs.

Can make plots using triangular tesselation and tri-versions of plots (e.g. trisurf, trimesh). Example of ionosphere plot:
![vx](NoteFigures/IonosphereSurf.png)

### September 5, 2016 ###
Correlation of model-predicted V_x using solar wind input V_x:
![vx](figures/PNGs/ModelModelCorrelation_ux.png)

Correlation of Ionospheric region (2.8-3 R_E):
![ion](NoteFigures/IonosphereScatter3.png)

Attempt at a [stereographic projection](https://www.uwgb.edu/dutchs/STRUCTGE/sphproj.htm):
![stereo](NoteFigures/StereographicIonosphere.png)

Top and bottom hemispheres of the ionosphere cut:
![twoplot](NoteFigures/IonospherePolarCuts.png)


### September 1, 2016 ###
Trying to make correlation plots. This takes quite a while and 5.5GB of memory. This is manageable with scatter3, but isosurface and contourslice require regridding to a meshgrid format which returns "Maximum variable size allowed by the program is exceeded."

Two examples of attempts to plot with scatter3 though:
![all](NoteFigures/CorrFullScatter3.png)

Or only looking at points with correlations between 0.9+-0.01:
![poi](NoteFigures/CorrPOIScatter3.png)

Note that just looking at cutplanes doesn't reveal much of use, and an eps plots including every point take up 50+MB (and it's been generating a png for like 40 minutes so far and won't abort so calling it a night with this for now).


### August 31, 2016 ###
Beginning by trying to extend correlation tests to 3D space. This runs into a few issues: First being that Brian's code pre-cuts data into slices, so either the original cdf must be used, or his code must be run for each desired slice. I've chosen the former.

The next problem is that the original cdf is on a non-uniform grid with increasing grid density nearer to the Earth, and consists of over 1M grid points for 97 time steps. Even if we only take x,y,z,bx,by,bz, and rho, that's ~800Mb of memory just for storage. This is largely unavoidable because even if I interpolate to a uniform 100x100x100 grid, that's still the same size, but this does make the actual plots a bit nicer to look at.

For example, using scatter3 with interpolated data:
![interp](NoteFigures/InterpScatter3.png)
Versus using the original non-uniform grid:
![original](NoteFigures/OriginalScatter3.png)

It's also possible to use MATLAB's isosurface to directly draw a surface at a certain value, though this requires inputs in the form of a meshgrid which is (I think) easier if the grid is already uniform. Example (note this is a screen-grabbed png because MATLAB 2014a refuses to print the figure without it coming out corrupt. Known issue, and usually setting facelighting to 'phong' avoids it, but not in this case for some reason):
![iso](NoteFigures/InterpISO.png)

Next step will be actual correlation values and any issues with keeping all of that data in memory/running it through least squares.
