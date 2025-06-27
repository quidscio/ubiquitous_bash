# Anchors - A Fundamental Building Block
Ubiquitous_bash.sh (UBI), enables application developers and integrators to package complex application stacks. Whether the executable is Windows or Linux based, and whether run as a Windows or Linxu app, UBI packages an application and dependencies allowing users to easily install and run from either environment. Notably, UBI includes numerous helper functions such as for translating file paths between Windows and Linux environments. 

"Anchors" are the fundamental way users engage with custom UBI apps. We will first explore how an anchor is used and how it works. Then, we'll explore creating one or more anchors to package an example function. For now, consider anchors as an application executable. 

## Interacting With Anchors

### Batch file execution or File Association in Explorer 

A batch file calls an existing function with parameters. This batch file could be associated with specific file types in Explorer. 

One example use would be opening an untrusted file in a read/only virtual machine giving the user moderate protection from exploitation. UBI provides read-only, limited scope virtualization options as well as file-path translation.  

## Creating Anchors
1. Forking UBI to a Custom Application and Adding Function
All ubiquitous features contribute to creating multi-OS, self-contained application stacks. Ubiquitous_bash becomes yours. 
One example use would be adding support for simplified adoption of Docker container applications avoiding the need to manually configure dependency stacks and local filesystem mounts. Users need only a single command to get started, "_runMyAppNow". 
1. Adding an UBI library function 
This approach allows you to contribute back to the core ubiquitous capability and is suitable for small increments to existing capability or larger, must-have additions. For example, you could contribute a custom function to create unique session ids. Of course, UBI already has _uid for this purpose :heavy_check_mark:  .
1. Adding an UMI experimental "kit" function 
This approach is the hacker's playground and we won't attempt to explain these "edge of the map - here be dragons :dragon:". There are kits to see in UBI's ./_lib/kit folder. 
<details>

```
    Current /kit folders
        all
        app
        backup-github
        containment
        install
        mod
        raspi
        ssh
        virtualization
```
</details>


## Forking UBI to a Custom Application and Adding Function
UBI provides two paths for additional function. 
1. Preferred, you'll use UBI "fork" to intantiate a stand-alone git-enabled project folder with UBI included as a submodule. You as the developer/integrator, have complete control over function and format while maintaining the capability to decide when and if to accept UBI submodule updates.  
1. You can also contribute back to UBI core capabilities by using git fork, making modifications to UBI, and potentially contributing back via pull request. This option is mentioned for completeness.  

### Note on ubiquitous_bash forking
A UBI fork is distinct from a git (github) fork. UBI forking is a procedure for creating a custom application package leveraging the tooling included in ubiquitous_bash.sh. 

# Adding an Anchor
## Overview of Anchor Add Process
1. Git clone ubiquitous_bash to a local folder. We'll use:
```
mkdir core
cd core
git clone https://github.com/mirage335-colossus/ubiquitous_bash.git
```
2. Copy the fork script into a new project folder: 
```
mkdir new-anchor
cp ubiquitous_bash/fork new-anchor/fork 
cd new-anchor
```
3. Edit the anchor template to customize devName and projectName: 
```
export devName="geniusDev"
export projectName="aNewAnchor"
```
4. Execute the fork script:
```
./fork 
```
5. Create new functions and anchor scripts: 
```
cd aNewAnchor
kwrite _prog/core.sh
|   _aHelloFunction() {
|       echo "Hello $(whoami)! Welcome to your new Anchor"
|   }
|
|   _aSomethingUBI() {
|       _messagePlain_good "Showing off a few ubiquitous_bash functions" 
|    
|       _color_demo 
|    
|       _dns 
|   }
```
6. In the same file, add an _refresh_anchors function to create new shell and batch anchors 
```
|_refresh_anchors() {
|    cp -a "$scriptAbsoluteFolder"/_anchor "$scriptAbsoluteFolder"/|_aHelloFunction
|    cp -a "$scriptAbsoluteFolder"/_anchor "$scriptAbsoluteFolder"/|_aSomethingUBI
|    cp -a "$scriptAbsoluteFolder"/_anchor.bat "$scriptAbsoluteFolder"/|_HelloFunction.bat
|    cp -a "$scriptAbsoluteFolder"/_anchor.bat "$scriptAbsoluteFolder"/|_aSomethingUBI.bat
|}
```
7. Regenerate ubiquitous_bash to include new functions and execute _anchor to create new Linux and Windows execution callers. 
```
./_compile.sh
./_anchor 
```

The anchor files are now ready. The new functions can be triggered via the anchors OR as ubiquitous_bash functions. 
```


####TODO Not quite right...
1. Git clone ubiquitous_bash to a local repository 
2. Add new function to an existing UB source file such as ./_prog\core.sh
3. If launching via a Windows *.bat file is desired, copy _anchor.bat from ./_lib/ubiquitous_bash/ to ./
4. Add new anchor(s) to _refresh_anchors function and place in ./_prog\core.sh. To add, insert a linux cp (copy) ./_anchor to ./_myNewAnchor  
5. Execute compile.sh to include new functions in generated ubiquitous_bash.sh. Note, during development, simply edit new functions in ./_local\ops.sh to avoid compile step  
6. Execute _anchor to create anchor files; _newFunction (a *nix shell function) and newFunction.bat (a Windows function)
