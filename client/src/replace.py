import os
path=input('C:\software\eth\metadata\json1')       
f=os.listdir(path)

n=0
for i in f:

    oldname=path+f[n] + '.json'
    newname=path+f[n]
    os.rename(oldname,newname)
    print(oldname,'======>',newname)

    n+=1