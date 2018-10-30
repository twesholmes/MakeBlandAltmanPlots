% -----------------------------------------------------------------------
%
%  This will create a pretty basic Bland Altman plot given two data sets
%  and the names that the user wants to assign to them.
%
%   Wesley Holmes 10/30/2018
%   twesholmes@gmail.com
%
% -----------------------------------------------------------------------
%
function MakeBlandAltmanPlots(data1,data2,data1Name,data2Name,TitleForPlots)
    %
    % Input Parameters
    %
    % data1 = the first data set - This is the existing value
    % data2 = the second data set - This is the trial against the existing value
    % data1Name = The name used along the x-axis for both plots - first data set name
    % data2Name = The name of the second data set along the y-axis of the Compairison
    % TitleForPlots = The name the user wants to assign the whole thing
    %


    %% First we need to figure out the size of the data sets and some other basic parameters
    SampleSize = size(data1,1);
    if SampleSize ~= size(data2,1)
        disp('You got a problem with the sizes of the data sets!')
        return
    end
    
    % The maximum value of all the data
    MaxVal = max(data1(:));
    if MaxVal < max(data2(:))
        MaxVal = max(data2(:));
    end    
    % That is then used to determine the sizes of the plots
    PlotLimit = (ceil(MaxVal)+25);
    ReferenceLine = [0,PlotLimit];

    % Determining the 
    p = polyfit(data1,data2,1);  % performing a 1D polynomial fit y=mx+b
    f1 = polyval(p,ReferenceLine); % This is then fitting the equation over the bounds to be used with the plotting
    
    % Now we can calculate the r^2 value of the fit
    y = data2;
    yCalc = polyval(p,data1);
    Rsq = 1 - sum((y - yCalc).^2)/sum((y - mean(y)).^2);

    % With the stats now found, we can create a string to be shown on the plot
    TextString1 = sprintf(' n=%d \n y=%3.2f*x + %3.2f \n r^{2}=%3.2f',SampleSize,p(1),p(2),Rsq);
    
    % This places each call into a new figure
    figure1 = figure;
    
    % Setting the background color to while for the whole subplot
    set(gcf,'color','w');
    
    % Constructing the first subplot for the compairisons of each data set
    axes1 = subplot(1,2,1);
    hold(axes1,'on');
    axis equal
    ylim(axes1,[0 PlotLimit]);
    xlim(axes1,[0 PlotLimit]);
    plot(ReferenceLine,ReferenceLine, 'DisplayName','Reference Line','Color', 'k')
    plot(data1,data2,'Marker','*','LineStyle','none', 'DisplayName','Value')
    plot(ReferenceLine,f1,'--', 'DisplayName','Linear Fit', 'Color', 'blue')
    xlabel(data1Name);
    ylabel(data2Name);
    title('Comparison Plot');
    legend(axes1,'show','Location','southeast');
    text(axes1, 0.05, 0.9, 0.0, TextString1, 'Units', 'normalized');

    %% Now, we can plot the difference of the existing with ECACS and then
    % determine a linear fit

    % First we need to do some calculations of the data set using the difference between the two data sets
    Difference = data2 - data1;       
    [p] = ttest2(data1,Difference); % Performing the two-tailed t-test and only using the p value 
    MeanDifference = mean(Difference); % calculating the mean of the difference set
    STDDifference = std(Difference); % finding out the standard deviation of the difference set
    UpperBound = MeanDifference + STDDifference * 1.96; % This is for determing the bounds of what is acceptable. 
    LowerBound = MeanDifference - STDDifference * 1.96; % + and - 1.96*STD is just standard practice for Bland Altman test

    % With the statistictics figured out, we can save them to a text string
    % to show the user when it is completed.
    TextString2 = sprintf('Two-Sampled t-test \n p = %5.4e', p);

    % Constructing the next subplot that will create the difference plot
    axes2 = subplot(1,2,2);
    hold(axes2,'on');
    axis equal
    ylim(axes2,[-PlotLimit/2 PlotLimit/2]); % This keeps the dimensions of both plots similar
    xlim(axes2,[0 PlotLimit]);
    h1 = plot([0 PlotLimit], [0 0], 'DisplayName','Reference Line','Color', 'k');
    h2 = plot(data1,Difference,'Marker','*','LineStyle','none', 'DisplayName','Value');
    h3 = plot([0 PlotLimit],[MeanDifference MeanDifference],'--', 'DisplayName','Mean', 'Color', 'blue');
    plot([0 PlotLimit],[UpperBound UpperBound],'--', 'DisplayName','Upper Mean', 'Color', 'blue')
    plot([0 PlotLimit],[LowerBound LowerBound],'--', 'DisplayName','Lower Mean', 'Color', 'blue')
    xlabel(data1Name);
    ylabel(sprintf('Difference between %s and %s',data1Name, data2Name));
    title('Difference Plot');
    legend(axes2,[h1 h2 h3],{'Reference Line','Value', 'Mean'})
    text(axes2, PlotLimit, UpperBound+10, 0.0,     sprintf('+1.96*STD=%3.2f ',UpperBound));
    text(axes2, PlotLimit, MeanDifference, 0.0, sprintf(' mean=%3.2f(%3.2f)',MeanDifference,STDDifference));
    text(axes2, PlotLimit, LowerBound-10, 0.0,     sprintf('-1.96*STD=%3.2f ',LowerBound));
    text(axes2, 0.05, 0.9, 0.0, TextString2, 'Units', 'normalized');    
    
    
    % Adding a title to the top of the two subplots
    axes( 'Position', [0, 0.95, 1, 0.05] ) ;
    set( gca, 'Color', 'None', 'XColor', 'White', 'YColor', 'White' ) ;
    text( 0.5, 0, TitleForPlots, 'FontSize', 14', 'FontWeight', 'Bold', ...
      'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Bottom' ) ;
        
end



















