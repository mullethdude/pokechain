
use blake2s::blake2s;


const MAX_ROLL: field = 20; 


fn hash_to_roll(seed: field) -> field {
   
    let mut bytes: [u8; 32] = [0u8; 32];
    let mut tmp = seed;
    let mut i = 0usize;
    while i < 32 {
        bytes[i] = (tmp & 0xffu128) as u8;
        tmp = tmp / 256u128;
        i = i + 1;
    }

    let digest = blake2s(bytes);
  
    let mut v: u128 = 0u128;
    let mut j = 0usize;
    while j < 8 {
        v = v + ((digest[j] as u128) * (256u128.pow(j as u32)));
        j = j + 1;
    }
    
    let roll = (v % (MAX_ROLL + 1u128)) as field;
    roll
}

fn apply_damage(att_stat: field, def_stat: field, att_roll: field, def_roll: field) -> field {
    
    let raw: field = att_stat + att_roll - def_stat - def_roll;
    
    let is_positive: bool = raw > 0;
    if is_positive {
        raw
    } else {
        0
    }
}

fn min_field(a: field, b: field) -> field {
    let cond: bool = a < b;
    if cond { a } else { b }
}


fn main(
    
    nft1_id: field,
    nft2_id: field,
    nft1_max_hp: field,
    nft2_max_hp: field,
    
    nft1_attack_stat: field,
    nft1_defense_stat: field,
    nft1_seed: field,
    nft2_attack_stat: field,
    nft2_defense_stat: field,
    nft2_seed: field,
) -> (field, field, field) {
    
    let nft1_att_roll = hash_to_roll(nft1_seed + 1u128);
    let nft1_def_roll = hash_to_roll(nft1_seed + 2u128);
    let nft2_att_roll = hash_to_roll(nft2_seed + 1u128);
    let nft2_def_roll = hash_to_roll(nft2_seed + 2u128);

   
    let dmg_to_2 = apply_damage(nft1_attack_stat, nft2_defense_stat, nft1_att_roll, nft2_def_roll);
    let dmg_to_1 = apply_damage(nft2_attack_stat, nft1_defense_stat, nft2_att_roll, nft1_def_roll);

   
    let final_dmg_to_2 = min_field(dmg_to_2, nft2_max_hp);
    let final_dmg_to_1 = min_field(dmg_to_1, nft1_max_hp);

    
    let nft1_remaining = nft1_max_hp - final_dmg_to_1;
    let nft2_remaining = nft2_max_hp - final_dmg_to_2;

    
    let winner: field;
    if nft1_remaining > nft2_remaining {
        winner = 1u128;
    } else {
        if nft2_remaining > nft1_remaining {
            winner = 2u128;
        } else {
            winner = 0u128;
        }
    }

    
    (winner, nft1_remaining, nft2_remaining)
}
