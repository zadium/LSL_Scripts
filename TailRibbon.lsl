/**
    @name: TailRibbon
    @version: 1.0
    @updated: "2023-04-30 02:22:43"
    @revision: 378
    @localfile: ?defaultpath\Scripts\?@name.lsl
*/
TailRiboon()
{

    llParticleSystem([
       PSYS_PART_FLAGS,
            PSYS_PART_INTERP_COLOR_MASK
            //| PSYS_PART_FOLLOW_VELOCITY_MASK
            | PSYS_PART_INTERP_SCALE_MASK
            | PSYS_PART_EMISSIVE_MASK
            | PSYS_PART_WIND_MASK
//            | PSYS_PART_RIBBON_MASK
            ,
        PSYS_SRC_PATTERN,           PSYS_SRC_PATTERN_ANGLE,
        //PSYS_SRC_TEXTURE,             llGetInventoryName(INVENTORY_TEXTURE, 0),
        //PSYS_SRC_OMEGA,<0, 0, 12*PI>,

        PSYS_SRC_BURST_RATE,        0.1,
        PSYS_SRC_BURST_PART_COUNT,  4,

        PSYS_SRC_ANGLE_BEGIN,       0.01*DEG_TO_RAD,
        PSYS_SRC_ANGLE_END,         0.01*DEG_TO_RAD,

        PSYS_PART_START_COLOR,      <1, 0, 0>,
        PSYS_PART_END_COLOR,        <1, 0, 0>,

        PSYS_PART_START_SCALE,      <1, 1, 0>,
        PSYS_PART_END_SCALE,        <1, 1, 0>,

        PSYS_SRC_BURST_SPEED_MIN,     1,
        PSYS_SRC_BURST_SPEED_MAX,     1,

  //      PSYS_SRC_BURST_RADIUS,      0.5,
        PSYS_SRC_MAX_AGE,           0,
        PSYS_SRC_ACCEL,             <0.0, 0.0, 0.0>,

        PSYS_PART_MAX_AGE,          10,

        PSYS_PART_START_GLOW,       0.0,
        PSYS_PART_END_GLOW,         0.0,

        PSYS_PART_START_ALPHA,      0.9,
        PSYS_PART_END_ALPHA,        0.9
    ]);
}

default
{
    state_entry()
    {
//        TailRiboon();
    llParticleSystem([]);
    }
}