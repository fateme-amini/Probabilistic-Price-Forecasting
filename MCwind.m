%% Wind Farm Portfolio Monte Carlo Simulation
% This code demonstrates Monte Carlo simulation for estimating expected
% energy production from a two-farm wind portfolio

clear; close all; clc;

rng(42); % Set seed for reproducibility

%% Wind Farm Parameters
% Farm 1 parameters
lambda1 = 10;  % Weibull scale parameter (m/s)
k1 = 2.0;      % Weibull shape parameter

% Farm 2 parameters  
lambda2 = 12;  % Weibull scale parameter (m/s)
k2 = 2.2;      % Weibull shape parameter

% Turbine power curve parameters (same for both farms)
v_ci = 3;      % Cut-in speed (m/s)
v_r = 12;      % Rated speed (m/s) 
v_co = 25;     % Cut-out speed (m/s)
P_r = 2000;    % Rated power (kW)

% Power curve coefficients for cubic region
a = P_r / (v_r^3 - v_ci^3);
b = -a * v_ci^3;

%% Monte Carlo Simulation Parameters
S_max = 10000;  % Maximum number of scenarios
S_step = 100;   % Step size for convergence analysis
S_values = S_step:S_step:S_max;  % Scenario counts to analyze

% Pre-allocate arrays for results
mean_estimates = zeros(size(S_values));
std_errors = zeros(size(S_values));
theoretical_std = zeros(size(S_values));

%% Analytical Expected Value Calculation (for reference)
% We'll use a large sample as our "true" expected value
S_true = 100000;
[v1_true, v2_true] = generate_wind_speeds(S_true, lambda1, k1, lambda2, k2);
[P1_true, P2_true] = calculate_power(v1_true, v2_true, v_ci, v_r, v_co, P_r, a, b);
true_expected_value = mean(P1_true + P2_true);

fprintf('Reference "true" expected value (from %d samples): %.2f kW\n', ...
        S_true, true_expected_value);

%% Main Monte Carlo Simulation Loop
fprintf('Running Monte Carlo simulation...\n');

for i = 1:length(S_values)
    S_current = S_values(i);
    
    % Generate wind speeds for current number of scenarios
    [v1, v2] = generate_wind_speeds(S_current, lambda1, k1, lambda2, k2);
    
    % Calculate power outputs
    [P1, P2] = calculate_power(v1, v2, v_ci, v_r, v_co, P_r, a, b);
    
    % Calculate total power for each scenario
    P_total = P1 + P2;
    
    % Store Monte Carlo estimator (sample mean)
    mean_estimates(i) = mean(P_total);
    
    % Calculate standard error (empirical)
    std_errors(i) = std(P_total) / sqrt(S_current);
    
    % Display progress
    if mod(i, 20) == 0
        fprintf('Completed %d/%d scenarios...\n', S_current, S_max);
    end
end

%% Calculate Theoretical Standard Error
% Estimate population variance from the full dataset
[v1_full, v2_full] = generate_wind_speeds(S_max, lambda1, k1, lambda2, k2);
[P1_full, P2_full] = calculate_power(v1_full, v2_full, v_ci, v_r, v_co, P_r, a, b);
P_total_full = P1_full + P2_full;
population_variance = var(P_total_full);

theoretical_std = sqrt(population_variance ./ S_values);

%% Create Convergence Plot
figure('Position', [100, 100, 1200, 800]);

% Main convergence plot
figure(1)
plot(S_values, mean_estimates, 'b-', 'LineWidth', 2, 'DisplayName', 'Monte Carlo Estimate');
hold on;
yline(true_expected_value, 'r--', 'LineWidth', 2, 'DisplayName', 'True Expected Value');

% Add confidence intervals
upper_ci = mean_estimates + 1.96 * theoretical_std;
lower_ci = mean_estimates - 1.96 * theoretical_std;
fill([S_values, fliplr(S_values)], [upper_ci, fliplr(lower_ci)], ...
     [0.8, 0.8, 1], 'EdgeColor', 'none', 'FaceAlpha', 0.3, ...
     'DisplayName', '95% Confidence Interval');

xlabel('Number of Scenarios (S)');
ylabel('Estimated Expected Power (kW)');
title('Monte Carlo Convergence for Wind Farm Portfolio', 'FontSize', 12);
legend('Location', 'best');
grid on;
xlim([0, S_max]);

% Add annotation about convergence rate
annotation('textbox', [0.15, 0.75, 0.3, 0.1], 'String', ...
    {'Convergence Rate: O(1/\surdS)', 'Estimate stabilizes as S increases'}, ...
    'FitBoxToText', 'on', 'BackgroundColor', 'white', 'EdgeColor', 'black','FontName','Times New Roman','FontSize',16);
a=gca;
a.FontName='Times New Roman';
a.FontSize=16;

%% Error Analysis Subplots

% Absolute error plot
figure(2);
absolute_error = abs(mean_estimates - true_expected_value);
semilogy(S_values, absolute_error, 'k-', 'LineWidth', 2);
hold on;

% Plot theoretical 1/sqrt(S) convergence
S_fit = linspace(S_step, S_max, 100);
error_fit = 2 * theoretical_std(1) ./ sqrt(S_fit/S_values(1));
semilogy(S_fit, error_fit, 'r--', 'LineWidth', 1.5, 'DisplayName', 'O(1/\surdS)');

xlabel('Number of Scenarios (S)');
ylabel('Absolute Error (kW)');
title('Estimation Error vs. Number of Scenarios');
legend('Actual Error', 'Theoretical O(1/\surdS)', 'Location', 'northeast');
grid on;

a=gca;
a.FontName='Times New Roman';
a.FontSize=32;

% Standard error plot
figure(3);
loglog(S_values, theoretical_std, 'g-', 'LineWidth', 2);
xlabel('Number of Scenarios (S)');
ylabel('Theoretical Standard Error');
title('Standard Error Convergence');
grid on;

% Add theoretical slope line
slope_line = theoretical_std(1) * (S_values(1)./S_values).^0.5;
hold on;
loglog(S_values, slope_line, 'm--', 'LineWidth', 1, 'DisplayName', 'Slope = -1/2');
legend('Standard Error', 'Theoretical Slope', 'Location', 'southwest');

a=gca;
a.FontName='Times New Roman';
a.FontSize=32;

%% Display Final Results
fprintf('\n=== SIMULATION RESULTS ===\n');
fprintf('Final Monte Carlo Estimate (%d scenarios): %.2f kW\n', S_max, mean_estimates(end));
fprintf('True Expected Value: %.2f kW\n', true_expected_value);
fprintf('Absolute Error: %.4f kW\n', abs(mean_estimates(end) - true_expected_value));
fprintf('Relative Error: %.4f%%\n', 100 * abs(mean_estimates(end) - true_expected_value) / true_expected_value);
fprintf('Theoretical Standard Error: %.4f kW\n', theoretical_std(end));

%% Helper Functions

function [v1, v2] = generate_wind_speeds(n, lambda1, k1, lambda2, k2)
    % Generate wind speeds using inverse transform sampling
    u1 = rand(n, 1);
    u2 = rand(n, 1);
    
    % Inverse Weibull CDF
    v1 = lambda1 * (-log(1 - u1)).^(1/k1);
    v2 = lambda2 * (-log(1 - u2)).^(1/k2);
end

function [P1, P2] = calculate_power(v1, v2, v_ci, v_r, v_co, P_r, a, b)
    % Calculate power output for both farms using the power curve
    
    % Initialize power arrays
    P1 = zeros(size(v1));
    P2 = zeros(size(v2));
    
    % Farm 1 power calculation
    P1(v1 < v_ci) = 0;
    in_range = (v1 >= v_ci) & (v1 < v_r);
    P1(in_range) = a * v1(in_range).^3 + b;
    P1(v1 >= v_r & v1 < v_co) = P_r;
    P1(v1 >= v_co) = 0;
    
    % Farm 2 power calculation
    P2(v2 < v_ci) = 0;
    in_range = (v2 >= v_ci) & (v2 < v_r);
    P2(in_range) = a * v2(in_range).^3 + b;
    P2(v2 >= v_r & v2 < v_co) = P_r;
    P2(v2 >= v_co) = 0;
end