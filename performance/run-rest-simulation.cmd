set GATLING_HOME=C:\Dev\gatling-charts-highcharts-bundle-3.5.1
set HELLO_PATH=C:\Dev\workspace\hello-prod-deploy

%GATLING_HOME%\bin\gatling.bat ^
-sf %HELLO_PATH%\performance\ ^
-s com.bee.perf.HelloSimulation ^
-rf %GATLING_HOME%\results
