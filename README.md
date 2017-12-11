## Introduction
This is the Matlab code for the ICASSP paper 'Registration based retargeted image quality assessment'.  

## How to run the code
Under the folder 'retargetme_codes', run the main.m function

## Folder structure
Our image retargeting assessment method runs based on the half-way domain image registration, SED edge detection and saliency map. We store all the intermediate results in the folder 'retargetme_data'. Please download this folder and place it under the root directory of the project. The folder is structured as following:

- 'source': all the original image
- 'resized_source': the resized source image
- 'BMS_output': stores the saliency map calculated by [1]
- 'segment_output': contains the result of salient objects and SED edges for each retargeting image
- Other folder: contains retargeted images for each source images. The registration flow is stored in the folder 'flow_overall'

## Other pre-requisite codes
If readers would like to generate all the intermediate results, you may refer to the following works:

- most of the half-way domain optimization is based on our previous paper [Automating Image Morphing using Structural Similarity on a Halfway Domain](https://github.com/liaojing/Image-Morphing). The code is written in C++.
- [Exploiting Surroundedness for Saliency Detection: A Boolean Map Approach ](http://cs-people.bu.edu/jmzhang/BMS/BMS.html)
- [Structured Edge Detection](https://github.com/pdollar/edges)
- [Salient Object Detection: A Discriminative Regional Feature Integration Approach](https://github.com/playerkk/drfi_matlab)

## References
Please cite our paper if your work is based on our method.

Zhang, Bo, Pedro V. Sander, and Amine Bermak. "Registration based retargeted image quality assessment." Acoustics, Speech and Signal Processing (ICASSP), 2017 IEEE International Conference on. IEEE, 2017.
