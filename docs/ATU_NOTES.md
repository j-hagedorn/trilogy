# Notes on ATU as a source for computational processing of folk tale motives

The ATU catalogue contains folk tales with their motives usually as with catalogue numbers in square brackets. Computational analysis of the folk tale motives using ATU relies on the assumption that the motives can be parsed from the source text without ambiguities using simple rules, such as regular expression match. For instance

```
155     The Ungrateful Snake Returned to Captivity. A man rescues a snake (wolf, bear, tiger) from a trap. In return the snake seeks to kill the rescuer [W154.2.1]. Other animals are asked if a good deed should be repayed with a bad one. The fox, as judge, asks the snake to show how it was trapped. The snake is tricked into captivity [J1172.3]. Cf. Types 331, 926A.
```

would parse as

```
155, W154.2.1, J1172.3
```

Such processing would then reflect the chain of motives that comprise a particular tale and using these motives it is possible to find structural and semanting regularities in the corpus. However, there are cases when it is not possible and the rigor of a strict parsing cast light on the loose concepts use in the text. As seen below the ATU corpus was not made with such processing on the mind and does not comply the strict and logical requirements of computational data processing.

Take the following example:

```
1692    The Stupid Thief. A fool joins a band of robbers. They send him into a house to steal while the rest of them wait outside. He bungles the job in one of several ways [J2136]: He takes the robbers instructions literally. They tell him to bring something substantial (i.e. valuable), and he brings something heavy (e.g. a mortar) [J2461.1.7]. They tell him to bring something shiny (i.e. gold), and he brings a mirror [J2461.1.7.1]. The fool awakens the household. He wants to take more than he can carry, so he wakes the owner and asks him for help [J2136.5.6]. The fool finds a musical instrument and plays it loudly [J2136.5.7]. He decides to cook something to eat. Hearing the owner sigh in his sleep, the fool thinks he must be hungry, so he puts hot food in his mouth (hand) [J2136.5.5]. Cf. Types 177, 1693.
```

This tale would parse to

```
1692, J2136, J2461.1.7, J2461.1.7.1, J2136.5.6, J2136.5.7, J2136.5.5
```

that is obviously wrong, as the last three motives belong to different endings, thus correctly the result should be somethink like this:

```
1692, J2136, J2461.1.7, J2461.1.7.1, J2136.5.6
1692, J2136, J2461.1.7, J2461.1.7.1, J2136.5.7
1692, J2136, J2461.1.7, J2461.1.7.1, J2136.5.5
```

The motives discussed above belong to the `J2136.5. Careless thief caught` category and look terminal motives, indeed:

```
J2136.5.6.   Foolish thief asks help of owner. Caught.
J2136.5.7.   Thieving numskull beats drum (blows trumpet, etc.) he finds in outhouse.
J2136.5.5.   Foolish thief cooks food and awakens household. Caught.
```

It is difficult or just too much work to eliminate these ambiguities programmatically. A human annotation would not only be faster and cheaper, but also more efficient in this case.

Let's turn to a different problem, namely the relation of the motives in the tale. Let's consider the J2461 motives that are also part of the tale:

```
J2461.1.   Literal following of instructions about actions.
J2461.1.7. Numskull told to steal something heavy brings millstone.
J2461.1.7.1. Numskull as thief: tries to carry off grinding-stone when told by confederates to bring out heavy things. Told to bring shiny things; brings out looking glass.
```

How can we understand the sequence of `J2461.1.7, J2461.1.7.1` ? Are they variants of the same tale or are they consecutive elements of the tale in a given order? Our parsing would suggest consecutive elements but reading the text these more look like similar motives that can be repeated in a tale multiple times.

Checking out the leading motif, `J2136 Numskull brings about his own capture` looks more like the summary or type of the tale or the type of it than a motifbut our parsing would put it as the leading motif.

Take an other example:

```
1341A   The Fool and the Robbers. (Including the previous Type 1341B*.) This tale exists chiefly in three different forms:
(1) Robbers stumble over a fool lying on the ground and wonder, "What is this, a log?" The fool answers, "Does a log have five annas in its pocket?
" When the robbers have taken away his money, the fool says, "Ask the merchant in the tree if my money is good." Thus the thieves rob the merchant, too [J2356]. Cf. Type 1577*.
(2) Three numskulls hide when they see thieves coming. The thieves find one of them, kill him, and wonder why his blood is so dark (red). On hearing this remark, the second numskull explains from his hiding place that it is because he has eaten blackberries (prickly pears). When the second numskull is killed, the thieves remark, "If this one had not spoken we would not have found him." The third explains aloud, "That's why I didn't say anything." The thieves kill him, too [J581, J2136].
(3) Two foolish slaves are recaptured because of their talkativeness [J581, J2136]. (Previously Type 1341B*.)

```

Taking the end motives of the second variant

```
J581  Wisdom and Folly,Foolishness Of Noise-Making When Enemies Overhear
J2136 Numskull brings about his own capture.
```

We see that these two motives a synonimes and not variants.
