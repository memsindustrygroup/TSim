% © 2012-2016 NXP Semiconductor N.V..  All rights reserved.
% SPDX-License-Identifier: BSD-3-Clause
% The BSD 3-clause license for this file can be found in the license.pdf file included with this 
% distribution or at https://spdx.org/licenses/BSD-3-Clause.html

classdef PhysicalSensorPodInterface
    
    properties
    end
    
    methods (Abstract)
        % These methods should be implemented for physical sensors
        [sz] = num_points(psp)
        [time] = get_time(psp)
        [psp] = initialize_models(psp)
        [a, m, av, t, ap] = get_samples(psp, i)
        [a] = get_acc_sample(psp, i)
        [m] = get_mag_sample(psp, i)
        [g] = get_gyro_sample(psp, i)
        [t] = get_temperature_sample(psp, i)
        [ap] = get_air_pressure_sample(psp, i)
        [psp] = corrupt(psp)
    end
end

