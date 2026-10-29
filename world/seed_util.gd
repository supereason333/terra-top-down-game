class_name SeedUtil

static func combine(a: int, b: int) -> int:
    return hash([a, b])

static func rng_for(base_seed: int, index := 0) -> RandomNumberGenerator:
    var rng := RandomNumberGenerator.new()
    rng.seed = hash([base_seed, index])
    return rng
