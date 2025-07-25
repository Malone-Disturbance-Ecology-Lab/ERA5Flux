
# Load the reticulate package
library(reticulate)

# Use the source_python function to run the Python script
source_python("\\\\corellia.environment.yale.edu\\MaloneLab\\Research\\WUE_CUE\\code\\function\\add_numbers.py")

# Now, you can call the Python function 'add_numbers' in R
result <- add_numbers(5, 7)
print(result)  # Should print 12