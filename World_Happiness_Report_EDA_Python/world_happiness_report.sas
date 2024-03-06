libname final "/home/u63495145/FinalProject";

proc print data=final.data_2017;run;
proc print data=final.data_2018;run;
proc print data=final.data_2019;run;

%macro merge_datasets();

  /* Create an empty merged_data dataset */
  data merged_data;
    set final.data_2017(in=in_2017) final.data_2018(in=in_2018) final.data_2019(in=in_2019);

    /* Identify the year for each dataset */
    if in_2017 then Year = 2017;
    else if in_2018 then Year = 2018;
    else if in_2019 then Year = 2019;

    /* Output to the merged_data dataset */
    output merged_data;
  run;

%mend;

/* Call the macro */
%merge_datasets();

/*Obtain statistics*/
proc print data=merged_data;
proc means data=merged_data;
proc freq data=merged_data;

/*Correlate variables to understand the relationship between factors*/
proc corr data=merged_data;
  var Overall_rank Score GDP_per_capita Social_support Healthy_life_expectancy Freedom_to_make_life_choices Generosity Perceptions_of_corruption Year;
run;

/*Determine which factor contributes most to the happiness score*/
proc reg data=merged_data;
  model Score = GDP_per_capita Social_support Healthy_life_expectancy Freedom_to_make_life_choices Generosity Perceptions_of_corruption;
run;

/* Plot Canada's score over the years */
proc sgplot data=merged_data;
  where Country_or_region = "Canada";
  series x=Year y=Score / markers;
  title "Canada's Happiness Score Over the Years";
  yaxis label="Happiness Score";
  xaxis label="Year";
run;

/* Determine which factor contributes most to Canada's happiness score */
proc reg data=merged_data;
  model Score = GDP_per_capita Social_support Healthy_life_expectancy Freedom_to_make_life_choices Generosity Perceptions_of_corruption / influence;
  where Country_or_region = "Canada";
run;

proc corr data=merged_data(where=(Country_or_region='Canada'));
  var Overall_rank Score GDP_per_capita Social_support Healthy_life_expectancy Freedom_to_make_life_choices Generosity Perceptions_of_corruption Year;
run;

/*Examine how happiness scores and the contributing factors have changed over the years.*/

proc glm data=merged_data plots=diagnostics;
  class Year;
  model Score = Year GDP_per_capita Social_support Healthy_life_expectancy Freedom_to_make_life_choices Generosity Perceptions_of_corruption / solution;
run;

/* Calculate average values by year */
proc means data=merged_data mean;
  class Year;
  var Score GDP_per_capita Social_support Healthy_life_expectancy Freedom_to_make_life_choices Generosity Perceptions_of_corruption;
  output out=means_data mean=Mean_Score Mean_GDP Mean_Social Mean_Health Mean_Freedom Mean_Generosity Mean_Corruption;
run;

/* Create line plots for each variable's average over the years */
proc sgplot data=means_data;
  title "Average Values Over the Years";
  series x=Year y=Mean_GDP / markers lineattrs=(color=red);
  series x=Year y=Mean_Social / markers lineattrs=(color=green);
  series x=Year y=Mean_Health / markers lineattrs=(color=orange);
  series x=Year y=Mean_Freedom / markers lineattrs=(color=purple);
  series x=Year y=Mean_Generosity / markers lineattrs=(color=brown);
  series x=Year y=Mean_Corruption / markers lineattrs=(color=gray);
  keylegend / position=bottom;
  xaxis label="Year";
  yaxis label="Mean Value";
run;

/* Summarize happiness scores and factors by region */
proc means data=merged_data mean;
  class Country_or_region;
  var Score GDP_per_capita Social_support Healthy_life_expectancy Freedom_to_make_life_choices Generosity Perceptions_of_corruption;
  output out=summary_data mean=Mean_Score Mean_GDP Mean_Social Mean_Health Mean_Freedom Mean_Generosity Mean_Corruption;
run;

/* Sort the summarized data by country with the highest happiness score */
proc sort data=summary_data;
  by descending Mean_Score;
run;

/* Display the sorted summarized data */
proc print data=summary_data noobs;
  title "Summarized Happiness Scores and Factors by Country (Means for 3 Years)";
  var Country_or_region Mean_Score Mean_GDP Mean_Social Mean_Health Mean_Freedom Mean_Generosity Mean_Corruption;
run;

/* Scatterplot for entire data*/
proc sgscatter data=merged_data;
matrix Score GDP_per_capita;
run;

proc sgscatter data=merged_data;
matrix Score Social_support;
run;

proc sgscatter data=merged_data;
matrix Score Healthy_life_expectancy;
run;

proc sgscatter data=merged_data;
matrix Score Freedom_to_make_life_choices;
run;

proc sgscatter data=merged_data;
matrix Score Generosity;
run;

proc sgscatter data=merged_data;
matrix Score Perceptions_of_corruption;
run;

/*Regression Model and Outlier & Influence Analysis*/
proc reg data=merged_data plot(label)=(Residualplot residualbypredicted qqplot rstudentbyleverage cooksd dfbetas);
model score = GDP_per_capita Social_support Healthy_life_expectancy Freedom_to_make_life_choices Generosity Perceptions_of_corruption/partial;
output out=galanewres r=residual p=predicted h=leverage cookd=cookd student=ISR;
run;

/*Comparing Factors of Canada to Finland from 2019*/

/* Filter the data for the year 2019 and countries Finland and Canada */
data compare_data;
  set final.data_2019;
  where Country_or_Region in ('Finland', 'Canada');
run;

/* Bar graph for Score comparison in 2019 */
proc sgplot data=compare_data;
  vbar Country_or_Region / response=Score group=Country_or_Region 
                          datalabel=Score datalabelpos=top;
  title 'Comparison of Score for Finland and Canada (2019)';
run;

/* Bar graph for GDP_per_capita comparison in 2019 */
proc sgplot data=compare_data;
  vbar Country_or_Region / response=GDP_per_capita group=Country_or_Region 
                          datalabel=GDP_per_capita datalabelpos=top;
  title 'Comparison of GDP_per_capita for Finland and Canada (2019)';
run;

/* Bar graph for Social_support comparison in 2019 */
proc sgplot data=compare_data;
  vbar Country_or_Region / response=Social_support group=Country_or_Region 
                          datalabel=Social_support datalabelpos=top;
  title 'Comparison of Social_support for Finland and Canada (2019)';
run;

/* Bar graph for Perceptions_of_corruption comparison in 2019 */
proc sgplot data=compare_data;
  vbar Country_or_Region / response=Perceptions_of_corruption group=Country_or_Region 
                          datalabel=Perceptions_of_corruption datalabelpos=top;
  title 'Comparison of Perceptions_of_corruption for Finland and Canada (2019)';
run;

/* Bar graph for Healthy_life_expectancy comparison in 2019 */
proc sgplot data=compare_data;
  vbar Country_or_Region / response=Healthy_life_expectancy group=Country_or_Region 
                          datalabel=Healthy_life_expectancy datalabelpos=top;
  title 'Comparison of Healthy_life_expectancy for Finland and Canada (2019)';
run;

/* Bar graph for Generosity comparison in 2019 */
proc sgplot data=compare_data;
  vbar Country_or_Region / response=Generosity group=Country_or_Region 
                          datalabel=Generosity datalabelpos=top;
  title 'Comparison of Generosity for Finland and Canada (2019)';
run;

/* Bar graph for Freedom_to_make_life_choices comparison in 2019 */
proc sgplot data=compare_data;
  vbar Country_or_Region / response=Freedom_to_make_life_choices group=Country_or_Region 
                          datalabel=Freedom_to_make_life_choices datalabelpos=top;
  title 'Comparison of Freedom_to_make_life_choices for Finland and Canada (2019)';
run;