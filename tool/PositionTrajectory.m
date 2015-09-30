% Copyright (c) 2012, Freescale Semiconductor
classdef PositionTrajectory < AbstractTrajectory
    % The PositionTrajectory class is used to model positional offset,
    % velocity and acceleration.  It is often paired with the
    % AttitudeTrajectory class, which models orientation.
    
    properties (Access=public)
        RAWPT;  % Used to store piecewise linear set of initial data 
        P;      % Matlab time series used to model position
        V;      % Matlab time series used to model velocity
        A;      % Matlab time series used to model acceleration
        initial_velocity;   % 3X1 vector to model initial velocity when integrating from acceleration
        initial_position;   % 3X1 vector to model initial position when integrating from velocity
    end
    properties (Access=private)
        interpolation_method, type, computed;
    end
    
    methods (Access=private)
        function [traj] = init(traj, intp, time, data, type, units, tsName)
            % init() initializes position trajectory data structure
            % intp = interpolation method = 'linear' or 'spline'
            % data = input data structure (NX3 = X, Y, Z)
            % time = vector of time values
            % type = string identifier specifies input type
            % units = normally 'meters', 'meters/sec' or 'meters/sec/sec'
            % tsName = the name to use for the 1st (RAW) time series
            % computed is set to 1 after by the compute routine
            traj.startTime=min(time);
            traj.endTime=max(time);
            traj.interpolation_method=intp;
            traj.type=type;
            traj.computed=0;
            ts = timeseries(data, time);
            ts.DataInfo.Units=units;
            ts.set('Name', tsName);
            traj.RAWPT=ts;
        end
    end
    methods
        function [traj] = PositionTrajectory(name)
            traj = traj@AbstractTrajectory(name);
            traj.type='none';
            traj.initial_velocity = [0;0;0];
            traj.initial_position = [0;0;0];
        end
        
        function [traj] = set_acceleration(traj, intp, time, data)
            traj = traj.init(intp, time, data, 'acceleration', 'meters/sec/sec', 'pwlAcc');
        end
        function [traj] = set_velocity(traj, intp, time, data)
            traj = traj.init(intp, time, data, 'velocity', 'meters/sec', 'pwlVel');
        end
        function [traj] = set_position(traj, intp, time, data)
            traj = traj.init(intp, time, data, 'position', 'meters', 'pwlPos');
        end
        function [traj] = set_initial_position(traj, initial_position)
            traj.initial_position = initial_position;
        end
        function [traj] = set_initial_velocity(traj, initial_velocity)
            traj.initial_velocity = initial_velocity;
        end
       
        % Begin definition of abstract classes from class "trajectory"
        function [traj] = compute(traj, inc2, filter_numerator, filter_denominator)
            % compute() does basic computations for a trajectory
            % traj = Positiontrajectory class instance
            % inc = time increment to use for interpolation.  If equal to
            % zero, interpolation is skipped.
            % The input variable can be subject to "standard Matlab
            % filtering" if both filter_numerator and filter_denominator
            % are not empty (filtering is skipped if either is empty).
            if (inc2>0)
                % We will not interpolate inputs if inc=0
                newTimePoints = traj.startTime:inc2:traj.endTime;
                myFuncHandle = @(new_time, time, data)...
                    interp1(time, data, new_time,...
                    traj.interpolation_method);
                myInterpObj = tsdata.interpolation(myFuncHandle);
            else
                fprintf('Skipping interpolation step due to supplied time increment <= 0\n');
            end
            if (strcmp(traj.type, 'none'))
                fprintf('There is NO POSITION data to compute for this trajectory.\n');
            elseif (strcmp(traj.type, 'position'))
                if (inc2>0)
                    [traj.P] = traj.copyTimeSeries(traj.RAWPT, 'Position');
                    [traj.P] = setinterpmethod(traj.P,myInterpObj);
                    [traj.P] = resample(traj.P, newTimePoints);
                elseif (isempty(traj.P))
                    error('Position time series has not been loaded nor interpolated from scratch.\n');
                end
                [traj.P] = traj.optional_filter(traj.P, filter_numerator, filter_denominator);
                [traj.V] = traj.differentiate(traj.P, 'Velocity');
                [traj.A] = traj.differentiate(traj.V, 'Acceleration');
                traj.computed = 1;
            elseif (strcmp(traj.type, 'velocity'))
                if (inc2>0)
                    [traj.V] = traj.copyTimeSeries(traj.RAWPT, 'Velocity');
                    [traj.V] = setinterpmethod(traj.V,myInterpObj);
                    [traj.V] = resample(traj.V, newTimePoints);
                elseif (isempty(traj.V))
                    error('Velocity time series has not been loaded nor interpolated from scratch.\n');
                end
                [traj.V] = traj.optional_filter(traj.V, filter_numerator, filter_denominator);
                [traj.P] = traj.integrate(traj.V, 'Position', 'meters', traj.initial_position);
                [traj.A] = traj.differentiate(traj.V, 'Acceleration');
                traj.computed = 1;
            elseif (strcmp(traj.type, 'acceleration'))
                if (inc2>0)
                    [traj.A] = traj.copyTimeSeries(traj.RAWPT, 'Acceleration');
                    [traj.A] = setinterpmethod(traj.A,myInterpObj);
                    [traj.A] = resample(traj.A, newTimePoints);
                elseif (isempty(traj.V))
                    error('Acceleration time series has not been loaded nor interpolated from scratch.\n');
                end
                [traj.A] = traj.optional_filter(traj.A, filter_numerator, filter_denominator);
                [traj.V] = traj.integrate(traj.A, 'Velocity', 'meters/sec', traj.initial_velocity);
                [traj.P] = traj.integrate(traj.V, 'Position', 'meters', traj.initial_position);
                traj.computed = 1;
            else
                str = sprintf('Invalid PositionTrajectory type %s found.  Results are invalid.', traj.type);
                error(str);
            end
            traj.A  = labelPoints(traj.RAWPT, traj.A);
            traj.V  = labelPoints(traj.RAWPT, traj.V);
            traj.P  = labelPoints(traj.RAWPT, traj.P);
            traj.RAWPT  = labelPoints(traj.RAWPT, traj.RAWPT);
        end
        function [newTraj] = retime_then_rotate_pt(traj, inc, RM)
            newTraj = traj.retime_pt(inc);
            newTraj = newTraj.rotate_pt(RM);
        end
        function [newTraj] = rotate_then_retime_pt(traj, inc, RM)
            newTraj = traj.rotate_pt(RM);
            newTraj = newTraj.retime_pt(inc);
        end
        function [newTraj] = retime_pt(traj, inc)
            newTraj = traj;
            % We never retime the RAWPT time series
            if (~isempty(newTraj.P))
                newTraj.P = traj.changeTimeIncrement(newTraj.P, inc);
            end
            if (~isempty(newTraj.V))
                newTraj.V = traj.changeTimeIncrement(newTraj.V, inc);
            end
            if (~isempty(newTraj.A))
                newTraj.A = traj.changeTimeIncrement(newTraj.A, inc);
            end
        end
        function [newTraj] = rotate_pt(traj, RM)
            newTraj = traj;
            if (~isempty(newTraj.RAWPT))
                newTraj.RAWPT = traj.rotate_in_place(newTraj.RAWPT, RM, 1)
            end
            if (~isempty(newTraj.P))
                newTraj.P = traj.rotate_in_place(newTraj.P, RM, 1);
            end
            if (~isempty(newTraj.V))
                newTraj.V = traj.rotate_in_place(newTraj.V, RM, 1);
            end
            if (~isempty(newTraj.A))
                newTraj.A = traj.rotate_in_place(newTraj.A, RM, 1);
            end
        end
        function [] = plot_pt_all(traj, dirName)
            if (nargin==1)
                dirName=''; % no jpegs will be saved
            end
            traj.plot_raw_pt_inputs(dirName);
            traj.plot_position_coords(dirName);
            traj.plot_velocity_coords(dirName);
            traj.plot_acceleration_coords(dirName);
            traj.plot_3D_trajectory(dirName);
        end

        function [traj] = plot_raw_pt_inputs(traj, dirName)
            if (traj.computed)
                figure;
                plot(traj.RAWPT);
                str = sprintf('Raw Input Data (%s)', traj.type);
                title(str);
                legend('X', 'Y', 'Z');
                if (nargin>1)
                    savePlot( dirName, 'traj_RAWPT.jpg' );
                end
            else
                error('You must compute your position trajectory before plotting it.');
            end
        end
        function [traj] = plot_position_coords(traj, dirName)
            if (traj.computed)
                figure;
                plot(traj.P);
                title('Position Data');
                legend('X', 'Y', 'Z');
                if (nargin>1)
                    savePlot( dirName, 'traj_P.jpg' );
                end
            else
                error('You must compute your position trajectory before plotting it.');
            end
        end
        
        function [traj] = plot_velocity_coords(traj, dirName)
            if (traj.computed)
                figure;
                plot(traj.V);
                legend('Vx=dX', 'Vy=dY', 'Vz=dZ');
                title('Velocity Data');
                if (nargin>1)
                    savePlot( dirName, 'traj_V.jpg' );
                end
            else
                error('You must compute your position trajectory before plotting it.');
            end
        end
        function [traj] = plot_acceleration_coords(traj, dirName)
            if (traj.computed)
                figure;
                plot(traj.A);
                legend('Ax=dX^2', 'Ay=dY^2', 'Az=dZ^2');
                title('Linear Acceleration Data (excluding gravity)');
                if (nargin>1)
                    savePlot( dirName, 'traj_A.jpg' );
                end
            else
                error('You must compute your position trajectory before plotting it.');
            end
        end
        
        function [traj] = plot_3D_trajectory(traj, dirName)
            if (traj.computed)
                figure
                str = sprintf('%s fit', traj.interpolation_method);
                if (strcmp(traj.type, 'position'))
                    plot3(traj.RAWPT.Data(:,1), traj.RAWPT.Data(:,2), traj.RAWPT.Data(:,3), 'r', ...
                        traj.P.Data(:,1), traj.P.Data(:,2), traj.P.Data(:,3), 'b', ...
                        traj.RAWPT.Data(:,1), traj.RAWPT.Data(:,2), traj.RAWPT.Data(:,3), 'ro', 'MarkerFaceColor', 'r');
                    legend('Input Trajectory', str, 'Input Points');
                else
                    plot3(traj.P.Data(:,1), traj.P.Data(:,2), traj.P.Data(:,3));
                    X=mean(get(gca,'Xlim'));
                    Y=mean(get(gca,'Ylim'));
                    Z=mean(get(gca,'Zlim'));
                    text(X,Y,Z,'Input timestamp markers are not shown.');
                end
                xlabel('X');
                ylabel('Y');
                zlabel('Z');
                title('3D trajectory');
                grid on;
                if (nargin>1)
                    savePlot( dirName, 'traj_3D_trajectory.jpg' );
                end

            else
                error('You must compute your position trajectory before plotting it.');
            end
        end
    end    % end of public method definitions
    methods (Access=private)

    end
    
end


