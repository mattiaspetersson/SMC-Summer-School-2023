# Workshop

The lab is about mapping body gestures to sound. We will use MediaPipe from Google ( https://developers.google.com/mediapipe)  that uses machine learning models for recognizing the body from a video stream like a web camera. We will map the positions of the joints to various audio parameters in order to create body gesture controlled instruments.
We will use WebAudioXML (WAXML) ( https://github.com/hanslindetorp/WebAudioXML) for the mapping strategies. WAXML can be implemented in any web page and runs on any device with a standard web browser. It is an XML language and parser that makes it possible to configure synthesizers, mixers, effect chains and adaptive music using XML only.
In this workshop we will focus on using the <var> object and its features for mapping values to fit the range of a parameter. We will then the frequency of an <OscillatorNode> and a <BiquadFilterNode> and also control the volume using the <GainNode>. This makes it possible to build a digital musical instrument that is controlled by your body.
Before we start the workshop, please make sure to:

1. Create an account and login at  https://editor.p5js.org/
2. Pick a sketch from my collection at  https://editor.p5js.org/hanslindetorp/collections/NO0-OlyqW
3. Duplicate and save it to your account
4. Open and edit the audio.xml file
5. Save it and test it directly in the browser
 
## WAXML Documentation:
https://github.com/hanslindetorp/WebAudioXML/wiki

### <var> and Parameter Mapping
https://github.com/hanslindetorp/WebAudioXML/wiki/var
https://github.com/hanslindetorp/WebAudioXML/wiki/Parameter-Mapping

### <OscillatorNode>
https://github.com/hanslindetorp/WebAudioXML/wiki/OscillatorNode

### <BiquadFilterNode>
https://github.com/hanslindetorp/WebAudioXML/wiki/BiquadFilterNode

### <GainNode>
https://github.com/hanslindetorp/WebAudioXML/wiki/GainNode


## References:
Whole Body
pose[0-32][x/y]
Ex: pose0x
Reference:
https://github.com/google/mediapipe/blob/master/docs/solutions/pose.md

## Hand
[left/right]Hand[0-20][x/y]
Ex: rightHand0x
Reference:
https://github.com/google/mediapipe/blob/master/docs/solutions/hands.md

## Face
face[0-][x/y]
Ex: face0x
Reference:
https://github.com/google/mediapipe/blob/master/docs/solutions/face_mesh.md

### Face map:
https://github.com/tensorflow/tfjs-models/blob/master/face-landmarks-detection/mesh_map.jpg
![image](https://github.com/mattiaspetersson/SMC-Summer-School-2023/assets/15527600/ad1c29dd-865f-4a99-a64d-3cb2e2b7d1ce)
