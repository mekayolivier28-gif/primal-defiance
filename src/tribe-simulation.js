// Primal Defiance — Tribe Simulation Layer
// Original gameplay logic; no Dawn of Defiance or Ancestors assets/code.
export const PERSONALITIES = ['Brave','Cautious','Curious','Loyal','Independent','Aggressive'];
export const ROLES = ['Forager','Hunter','Scout','Caretaker','Crafter'];

export function makeMember(id,name,personality=PERSONALITIES[Math.floor(Math.random()*PERSONALITIES.length)]) {
  return { id,name,personality,role:'Forager',age:18+Math.floor(Math.random()*28),hunger:100,fatigue:0,morale:70,loyalty:50,
    skills:{hunting:1+Math.floor(Math.random()*3),gathering:1+Math.floor(Math.random()*3),sensing:1+Math.floor(Math.random()*3),crafting:1+Math.floor(Math.random()*3),healing:1+Math.floor(Math.random()*3)},
    relationships:{},memories:[] };
}
export function addMemory(member,text,impact=0){member.memories.push({text,day:Date.now(),impact});member.memories=member.memories.slice(-12);member.morale=Math.max(0,Math.min(100,member.morale+impact));}
export function bond(a,b,amount=8){a.relationships[b.id]=Math.min(100,(a.relationships[b.id]||0)+amount);b.relationships[a.id]=Math.min(100,(b.relationships[a.id]||0)+amount);}
export function groupHunt(tribe){const hunters=tribe.members.filter(m=>m.role==='Hunter'),scouts=tribe.members.filter(m=>m.role==='Scout');const power=hunters.reduce((n,m)=>n+m.skills.hunting,0)+scouts.reduce((n,m)=>n+m.skills.sensing*.5,0);const success=power>=3||Math.random()<Math.min(.9,.25+power*.08);const food=success?Math.max(3,Math.floor(power*2)):0;hunters.forEach(m=>{m.fatigue=Math.min(100,m.fatigue+18);addMemory(m,success?'Returned from a successful group hunt.':'Returned from a difficult hunt.',success?3:-3)});return{success,food};}
export function endDay(tribe){const need=tribe.members.length*2,fed=tribe.food>=need;tribe.food=Math.max(0,tribe.food-(fed?need:tribe.food));tribe.members.forEach(m=>{m.hunger=Math.max(0,m.hunger-(fed?4:22));m.fatigue=Math.max(0,m.fatigue-15);m.morale=Math.max(0,Math.min(100,m.morale+(fed?2:-8)));if(!fed)addMemory(m,'The tribe went hungry.',-4)});tribe.day+=1;tribe.morale=Math.round(tribe.members.reduce((n,m)=>n+m.morale,0)/Math.max(1,tribe.members.length));return{fed,need};}
