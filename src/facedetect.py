import cv2
import numpy as np
import sys
input_image = (' '.join(sys.argv[1:]))
imagedir = './frames/'
inputdi = imagedir+input_image
face_cascade = cv2.CascadeClassifier("haarcascade_frontalface_default.xml")
eye_cascade = cv2.CascadeClassifier("haarcascade_eye.xml")
img = cv2.imread(inputdi)
gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
faces = face_cascade.detectMultiScale(gray, 1.1, 4)
for (x, y, w, h) in faces:

    if w < 200:
        print("0")
        sys.exit()
try:
    roi_gray = gray[y:(y+h), x:(x+w)]
except:
    print("0")
    sys.exit()

eyes = eye_cascade.detectMultiScale(roi_gray, 1.1, 4)
count = 0
for (ex, ey, ew, eh) in eyes:
    if count == 0:
        eye_1 = (ex, ey, ew, eh)
    elif count == 1:
        eye_2 = (ex, ey, ew, eh)
    count = count + 1
if eye_1[0] < eye_2[0]:
    lefteye = eye_1
    righteye = eye_2
else:
    lefteye = eye_2
    righteye = eye_1
left_eye_center = (int(lefteye[0] + (lefteye[2] / 2)),
                   int(lefteye[1] + (lefteye[3] / 2)))
lefteye_x = left_eye_center[0]
lefteye_y = left_eye_center[1]

right_eye_center = (
    int(righteye[0] + (righteye[2]/2)), int(righteye[1] + (righteye[3]/2)))
righteye_x, righteye_y = right_eye_center[:2]

height, width = img.shape[:2]


ref_y = 960/2
ref_x = 1920/2


cv2.line(img, ((x+righteye_x), (y+righteye_y)),
         ((x+lefteye_x), (y+lefteye_y)), (0, 200, 200), 3)


trans_x = (ref_x-(x+righteye_x))
trans_y = (ref_y-(y+righteye_y))


delta_x = (righteye_x) - (lefteye_x)
delta_y = (righteye_y) - (lefteye_y)
angle = np.arctan(delta_y/delta_x)
angle = (angle * 180) / np.pi
dist_1 = np.sqrt((delta_x * delta_x) + (delta_y * delta_y))


ratio = (130/(dist_1))
dim = ((int(width * ratio)), (int(height * ratio)))
center = (int(x+righteye_x), int(y+righteye_y))

M = cv2.getRotationMatrix2D(center, (angle), 1.0)
rotated = cv2.warpAffine(img, M, (width, height))
resized = cv2.resize(rotated, dim)
T = np.float32([[1, 0, (trans_x * ratio)], [0, 1, (trans_y * ratio)]])
translation = cv2.warpAffine(resized, T, dim)


heightmar1 = int(int(height*ratio)/4)
heightmar2 = int(int((height*ratio*3)/4))
widthmar1 = int((width*ratio)/4)
widthmar2 = int((width*ratio*3)/4)
crop_img = translation[heightmar1:heightmar2, widthmar1:widthmar2]

final = cv2.resize(crop_img, (1920, 960))

outputdir = './finalframes/'
outputdo = outputdir+input_image
writeStatus = cv2.imwrite(outputdo, final)
if writeStatus is True:
    print("1")
else:
    print("0")
