clc;
RM = rotate_x_degrees(45)
q = RM_to_quaternion(RM)
newRM = RM_from_quaternion(q)