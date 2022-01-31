

# Memento-mod

As web-scaling is more of a witchcraft than an exact science, it is currently on a **closed/invite-only beta** status.  
Please head to https://signup.memento.ma and register your email if you're interested, invite codes will follow.

---



## TL;DR

Memento is a cloud-based HUD for The Binding of Isaac game (AB+/Repentance). It gives you the ability to **track** your skill progress over time, to **share** your live/best runs to your friends, and **help** the community to explore the beautiful complexity and randomness of this game.

Demo


[![Local Demo](http://img.youtube.com/vi/jIz0HR7KQFY/0.jpg)](http://www.youtube.com/watch?v=jIz0HR7KQFY "Local Demo")

If you're a modder/speedrunner/dev, please check below and PM me \o/

Thanks for your time!

---

## What?
This pet project was originally an attempt to "port" **[BrokenRemote]( https://github.com/MasterQ32/BrokenRemote )** mod to Repentance, and reworking its UI to a more web-friendly one along the way.

Memento's mod became simply a way of **live datamining** the game's info and saving it on [*some else's computer*](https://en.wikipedia.org/wiki/Cloud_computing), thus allowing some interesting use-cases :

- As a player, you're not only able to track your skillz over the time, but also allows you to share your progress/Omega run with your friends.
- As a modder, it may be a great way to live debug/test your mod's impact on the game.
- As a speedrunner, this can be considered as a "Tool-Assisted" help to track/organize better tailored challenges/events.

## How?

The current repository shows what and how it sends the game's data live to the cloud.  

For the technicalities, the mod **reads game's data** and send it in TCP to a **cloud-based Golang backend server**. It does its magic with the data, and send it to a **VueJS frontend webpage** that graphs it live.

For obvious security reason, the backend is currently **closed-source** and it is structured in dev as following:
```
.
├── api-live                <- Handling live data from cache + write to DB + websockets
├── api-run                 <- Handling saved data in DB + read to DB
├── api-tcp                 <- TCP service live data + write to cache
├── api-user                <- Handling user data + invites
├── data                    <- local data storage
├── docker-compose.yml      <- Dev docker-compose
├── front-landing           <- Landing frontend
├── front-quasar            <- Beta frontend
├── notes.md                <- General notes
├── testtcp.py              <- TCP testing
└── tools                   <- Misc tools (sonarqube, elk ...)
```


To scale it from the usual "**it works on my machine**" to a stable service that can handle BOI's community globally, it needs some **spells and a steady steam of sacrifices to the cloud gods** : An **invite-only beta testing** is a solid way to achieve this. 

## Who?

- You're **just a Player**: Please head to https://signup.memento.ma and register your mail, I'll be sure to drop you an email as soon as it is stable enough.
- You're **Modder / BOI's API Expert**: I'm a Lua newbie, and I'm sure I didn't leverage all of it capabilities. I can only but thank you if you lay an eye on it.
- You're a **Graphic Designer / Golang/VueJS Dev**: Help wanted to make it pretty and steady \o/ Please drop me an PM
- You're a **Speedrunner / Streamer**: Please drop me an PM

Glad you made it this far! Big shout out to you and to BOI's community \o/


## Social

Reddit call for beta : https://www.reddit.com/r/themoddingofisaac/comments/ru91w2/call_for_betatesting_memento_a_webbased_hud_for/



> It's not the Deadgod but the adventure along the way.