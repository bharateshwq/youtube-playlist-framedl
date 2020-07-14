import cv2
import sys
a = (' '.join(sys.argv[1:]))
face_cascade = cv2.CascadeClassifier('haarcascade_frontalface_default.xml')
img = cv2.imread(a)
gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
faces = face_cascade.detectMultiScale(gray, 1.1, 4)
for (x,y,w,h) in faces:
    width = w
try:
    width
    if width > 200:
        print ("1")
    else:
        print ("0")
except NameError:
    print("0")
