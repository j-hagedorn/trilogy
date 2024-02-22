# Notes on ATU as a source for computational processing of folk tale motives

The ATU catalogue contains folk tales with their motives usually as with catalogue numbers in square brackets. Computational analysis of the folk tale motives using ATU relies on the assumption that the motives can be parsed from the source text without ambiguities using simple rules, such as regular expression match. For instance

155     The Ungrateful Snake Returned to Captivity. A man rescues a snake (wolf, bear, tiger) from a trap. In return the snake seeks to kill the rescuer [W154
.2.1]. Other animals are asked if a good deed should be repayed with a bad one. The fox, as judge, asks the snake to show how it was trapped. The snake is tri
cked into captivity [J1172.3]. Cf. Types 331, 926A.

would parse as

155, W154.2.1, J1172.3

However, there are cases when it is not possible and the rigor of a strict parsing cast light on the loose concepts use in the text.

1692    The Stupid Thief. A fool joins a band of robbers. They send him into a house to steal while the rest of them wait outside. He bungles the job in one of several ways [J2136]: He takes the robbers instructions literally. They tell him to bring something substantial (i.e. valuable), and he brings something heavy (e.g. a mortar) [J2461.1.7]. They tell him to bring something shiny (i.e. gold), and he brings a mirror [J2461.1.7.1]. The fool awakens the household. He wants to take more than he can carry, so he wakes the owner and asks him for help [J2136.5.6]. The fool finds a musical instrument and plays it loudly [J2136.5.7]. He decides to cook something to eat. Hearing the owner sigh in his sleep, the fool thinks he must be hungry, so he puts hot food in his mouth (hand) [J2136.5.5]. Cf. Types 177, 1693.

This tale would parse to

1692, J2136, J2461.1.7, J2461.1.7.1, J2136.5.6, J2136.5.7, J2136.5.5

that is obviously wrong, as the last three motives belong to different endings.

An other problem that this example reveals is that in the notation we may find the type of the tale also in square braces. In this case the first 'motif', the J2136 is the 'Numskull brings about his own capture'. However, this is not a motif but the whole class of tales, with variants as J2136.5.6, J2136.5.7 and J2136.5.5.

In this example not only the positional relation of the last three motives is wrong, but also the semantic relation of the J2136 motives.

WIP:
1341A
The text runs as following:
...The thieves kill him, too [J581, J2136]. (3) Two foolish slaves are recaptured because of their talkativeness [J581, J2136]...

J581,Wisdom and Folly,Foolishness Of Noise-Making When Enemies Overhear
J2136.1 Wisdom and Folly.

In our cleared data perhaps the correct flattened data lines would be:
"1341A",2,"J2356","J2136","J581"
"1341A",3,"J2356","J581","J2136"

thus:
"1341A",2,"J2356","J2136","J581"
"1341A",3,"J2356","J581","J2136"
that would lead to the hypothetical contraction as
"1341A",2,"J2356", ["J2136","J581"]
as J2136 & J581 are interchangeable variants. What is may mean check later.
