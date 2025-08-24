[README (中文)](README.zh_CN.md)

# Throwing Hunter (TurtleWoW 1.18.0) | Supports Chinese & English Clients Only

-----

### **How to Use**

1.  Place your throwing weapons and ranged weapons in your **main bag**.
2.  The addon will set action bar slot 1 to **Auto Shot** and slot 13 to the melee **Attack** (slot 13 is the first slot of the second action bar).
3.  After the addon loads, it will create 3 macros:
      - **H2E\_Attack:** Uses a melee ability within 7 yards, and ranged at greater than 7 yards. After an **Arcane Shot** followed by a **auto shot**, it will automatically switch to your **throwing weapon**. It will switch back to your **ranged weapon** after combat. When mana is low, it will use Rank 1 spells. It only switches to a **throwing weapon** within 28 yards. If you are in the Marksmanship specialization, you need to be closer to throw.
      - **H2E\_Save:** If you have a mouseover target, your pet will attack it. If an enemy in the vicinity is targeting you, your pet will attack it. It is recommended to bind this to your mouse wheel up/down.
      - **H2E\_Assist:** Assists with attacks. It will find a target marked with a **Cross** or a **Skull**. If no such target exists, it will find the Main Tank's target. Since the Main Tank is not explicitly set, it will find the target of a teammate who is being attacked (a teammate whose target's target is the teammate, and the teammate's target is it, then that teammate should be the Main Tank).

### **NOTE:**

Your throwing weapon will automatically switch after its durability is zero, but remember to delete the old throwing weapon or move it to a different bag.

If you do not have a pet, **H2E\_Attack** will prioritize casting **Call Pet**. If you do not want this feature, please delete this line in the `hunter.lua` file:

```lua
T.CastSpellByName(L.CALL_PET)
```