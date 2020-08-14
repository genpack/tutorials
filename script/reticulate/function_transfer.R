
pyscr = "
def my_add(x, y):
  return(x + y)

def my_mult(x, y):
  return(x*y)
"

reticulate::py_run_string(pyscr) %>% reticulate::py_to_r() -> mod
mod$my_add(3,4)
mod$my_mult(3,4)
############################

pystr = "
def my_add(x, y):
  return(x + y)

def call_function(func = my_add, *kwarg):
  func(*kwarg)
"
my_add_r = function(x, y){
  return(x + y)
}
my_add_py = reticulate::r_to_py(my_add_r, convert = T)

reticulate::py_run_string(pyscr) %>% reticulate::py_to_r() -> mod
mod$call_function(3, 4)
