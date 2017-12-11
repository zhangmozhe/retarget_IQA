function x = index_validate(x, lowerlimit, upperlimit)
x(x < lowerlimit) = lowerlimit;
x(x > upperlimit) = upperlimit;
end