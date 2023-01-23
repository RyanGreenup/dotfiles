function juliaImage --wraps='julia --threads=auto -J ~/.julia/environments/Current/JuliaSysimage.so' --description 'alias juliaImage=julia --threads=auto -J ~/.julia/environments/Current/JuliaSysimage.so'
  julia --threads=auto -J ~/.julia/environments/Current/JuliaSysimage.so $argv; 
end
