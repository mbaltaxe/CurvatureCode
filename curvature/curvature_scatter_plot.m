%curvature_scatter_plot

%this script can provide some guidelines if you want to plot scatter plots
%of curvature vs body length.

%It find the mean and standard deviation of a number of tests.
%For example: if you tested a robot 10 times and wanted to plot mean +
%stdev of curvature magnitude for this set of tests, 
%you could enter the test folder and this would load, average, and plot
%data for that folder.

%You may need to change the number of loops depending on how the file
%structure is organized.

clearvars; close all;

%UPDATE this variable if you are running a different test!
testName = 'A-StorageTime';

% whatever general path the images will be in
%inpath = sprintf( '/Users/roahm/Box Sync/FREEWearProject/%s', testName );
inpath = sprintf( '/Users/mbaltaxe/Dropbox (University of Michigan)/FREEWearProject/%s', testName );

%I suggest plotting the mean + standard deviation, but there is also an
%option to plot the total range of values if you set this to 0:
use_stdev = 1;

%can change RGB color!
robotColor = [217,95,2]/255;


%find the list of .mat files
snake_files = dir( sprintf( '%s/CurvatureStructs/*.mat', inpath );

for i = 1:length(snake_files)

    fileName = snake_files(i).name;

    %load the data struct
    data = load( sprintf( '%s/CurvatureStructs/%s',...
        inpath, fileName ) );
    data = data.data;

    %Get radius of curavture magnitudes
    R = data.R;

    curveLength = linspace( 0, 100, length(R) );

    K = 1./R;           %so the curvature is in 1/(% snake length) 

    %spline and resample so we have things as a function of curve length.
    K = spline( percent_length(11:490), K(11:490) ); 
    K = ppval( K, curveLength(11:490) )';
    K = [NaN(10, 1); K; NaN(10, 1)];

    robotCurveCon = [ robotCurveCon, K ];

end

if use_stdev

    robotMean = nanmean( robotCurveCon, 2 );
    robotStd = nanstd( robotCurveCon, 0, 2 );
    robotCurveUB = robotMean + robotStd;
    robotCurveLB = robotMean - robotStd;

else

    robotMean = nanmean( robotCurveCon, 2 );
    robotCurveUB = max(robotCurveCon, [], 2);
    robotCurveLB = min(robotCurveCon, [], 2); 

end

robotCurveUB( isnan(robotCurveUB) ) = 0;
robotCurveLB( isnan(robotCurveLB) ) = 0;

%% plot

sz = 2.5;

endPt = 500;

hFig = figure;
set(hFig, 'Position', [0 0 500 600])
set(gcf, 'defaulttextinterpreter', 'latex');

p3 = scatter( curveLength(1:endPt), robotMean(1:endPt), sz, 'MarkerEdgeColor', robotColor,...
    'MarkerFaceColor', robotColor ); 
hold on;

tmpC = [curveLength(1:endPt), fliplr(curveLength(1:endPt)) ];
inBetween2 = [ robotCurveLB(1:endPt)', fliplr( robotCurveUB(1:endPt)' )];

p4 = fill( tmpC, inBetween2, robotColor ); 

hold on;

set( p4, 'FaceAlpha', 0.5, 'EdgeAlpha', 0 );
  
xlabel( 'Body Length (\%)', 'FontSize', 16 );

ylabel( '$\mathcal{K}$ (Body Length$^{-1}$)', 'FontSize', 16 );


if use_stdev
    
    saveas( gcf, sprintf( '%s/CurvatureScatterPlot_StDev.pdf', inpath ) );

else
    
    saveas( gcf, sprintf( '%s/CurvatureScatterPlot_totalRange', inpath ) );
    
end