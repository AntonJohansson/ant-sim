const std = @import("std");
const raylib = @cImport({
    @cInclude("raylib.h");
    @cInclude("rlgl.h");
});

const Ant = struct {
    x: f32,
    y: f32,
    vel_x: f32,
    vel_y: f32,
};

const Vec2 = struct {
    x: f32,
    y: f32,
};

pub fn main() void {
    const width = 800;
    const height = 600;
    raylib.InitWindow(width, height, "floating");
    defer raylib.CloseWindow();
    raylib.SetTargetFPS(60);

    var prng = std.rand.DefaultPrng.init(0);
    const random = prng.random();

    const num_ants = 50;
    var ants_pos: [num_ants]Vec2 = undefined;
    var ants_vel: [num_ants]Vec2 = undefined;
    for (ants_pos) |*p| {
        p.x = width * random.float(f32);
        p.y = height * random.float(f32);
    }
    for (ants_vel) |*v| {
        v.x = 1000.0*(2.0 * random.float(f32) - 1.0);
        v.y = 1000.0*(2.0 * random.float(f32) - 1.0);
    }

    const scent_texture = raylib.LoadRenderTexture(width, height);
    defer raylib.UnloadRenderTexture(scent_texture);

    const shader = raylib.LoadShader(0, "src/scent.frag");
    defer raylib.UnloadShader(shader);

    const comp = raylib.LoadFileText("src/ants.comp");
    const ants_program = raylib.rlLoadComputeShaderProgram(raylib.rlCompileShader(comp, raylib.RL_COMPUTE_SHADER));
    raylib.UnloadFileText(comp);
    defer raylib.rlUnloadShaderProgram(ants_program);

    const ssbo_pos = raylib.rlLoadShaderBuffer(@sizeOf(Vec2) * num_ants, &ants_pos, raylib.RL_DYNAMIC_DRAW);
    const ssbo_vel = raylib.rlLoadShaderBuffer(@sizeOf(Vec2) * num_ants, &ants_vel, raylib.RL_DYNAMIC_DRAW);
    std.debug.assert(ssbo_pos != 0);
    std.debug.assert(ssbo_vel != 0);
    defer raylib.rlUnloadShaderBuffer(ssbo_pos);
    defer raylib.rlUnloadShaderBuffer(ssbo_vel);

    raylib.SetTextureWrap(scent_texture.texture, raylib.TEXTURE_WRAP_CLAMP);

    while (!raylib.WindowShouldClose()) {

        raylib.rlEnableShader(ants_program);
        raylib.rlBindShaderBuffer(ssbo_pos, 1);
        raylib.rlBindShaderBuffer(ssbo_vel, 2);
        raylib.rlComputeShaderDispatch(num_ants, 1, 1);
        raylib.rlDisableShader();

        raylib.rlReadShaderBuffer(ssbo_pos, &ants_pos, raylib.rlGetShaderBufferSize(ssbo_pos), 0);


        //for (ants) |*ant| {
        //    const dt = raylib.GetFrameTime();
        //    ant.x += dt * ant.vel_x;
        //    ant.y += dt * ant.vel_y;
        //    if (ant.x < 0 or ant.x > width) {
        //        ant.x = std.math.clamp(ant.x, 0, width);
        //        ant.vel_x = -ant.vel_x;
        //    }
        //    if (ant.y < 0 or ant.y > height) {
        //        ant.y = std.math.clamp(ant.y, 0, height);
        //        ant.vel_y = -ant.vel_y;
        //    }
        //}

        //raylib.BeginTextureMode(scent_texture);
        //for (ants) |*ant| {
        //    // Negate height to flip texture around the x-axis
        //    raylib.DrawCircle(@floatToInt(i32, ant.x),
        //                      height - @floatToInt(i32, ant.y),
        //                      2.0,
        //                      raylib.Fade(raylib.RED, 1));
        //}
        //raylib.EndTextureMode();

        //raylib.BeginTextureMode(scent_texture);
        //raylib.BeginShaderMode(shader);
        //raylib.DrawTextureEx(scent_texture.texture, .{.x = 0.0, .y = 0.0}, 0.0, 1.0, raylib.WHITE);
        //raylib.EndShaderMode();
        //raylib.EndTextureMode();

        raylib.BeginDrawing();
        raylib.ClearBackground(raylib.BLACK);

        raylib.DrawTexture(scent_texture.texture, 0, 0, raylib.WHITE);

        for (ants_pos) |*ant| {
            raylib.DrawCircle(@floatToInt(i32, ant.x),
                              @floatToInt(i32, ant.y),
                              2.0,
                              raylib.RED);
        }

        raylib.EndDrawing();
    }
}
