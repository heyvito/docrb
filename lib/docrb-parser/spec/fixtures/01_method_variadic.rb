# Returns the sum of the two provided arguments
#
# a - The first argument to be used in the sum
# b - The second argument to eb used in the sum
# c - Other arguments to be summed as well
#
# Returns the sum of the two arguments.
def sum(a, b, *c)
  a + b + c.sum
end
