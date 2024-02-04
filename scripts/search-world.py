#!/usr/bin/env python3
import anvil
import os
import math
from tqdm import tqdm
import multiprocessing
import signal


def main():
    base_path = '/path/to/region'
    min_x = -800
    max_x = 600
    min_z = -800
    max_z = 1000
    min_y = 60
    max_y = 120
    search(base_path, min_x, max_x, min_z, max_z, min_y, max_y)


def nearest_multiple(point, base=16):
    if point < 0:
        return base * math.floor(point / base)
    else:
        return base * math.ceil(point / base)


def search(base_path, min_x, max_x, min_z, max_z, min_y, max_y):
    # https://minecraft.tools/en/coordinate-calculator.php
    min_x = nearest_multiple(min_x)
    max_x = nearest_multiple(max_x)
    min_z = nearest_multiple(min_z)
    max_z = nearest_multiple(max_z)
    min_y = 16 * math.floor(min_y / 16)
    max_y = 16 * math.ceil(max_y / 16)
    print(f"beginning search from x={min_x},z={min_z},y={min_y} to x={max_x},z={max_z},y={max_y}")

    work = {}
    for block_x in range(min_x, max_x, 16):
        chunk_x = int(block_x / 16)
        region_x = chunk_x >> 5
        for block_z in range(min_z, max_z, 16):
            chunk_z = int(block_z / 16)
            region_z = chunk_z >> 5
            region_path = os.path.join(base_path, f'r.{region_x}.{region_z}.mca')
            if region_path not in work:
                work[region_path] = []
            for block_y in range(min_y, max_y):
                section_index = int(block_y / 16)
                work[region_path].append((chunk_x, chunk_z, section_index))

    jobs = 7
    original_sigint_handler = signal.signal(signal.SIGINT, signal.SIG_IGN)
    pool = multiprocessing.Pool(processes=jobs)
    results = pool.imap_unordered(search_region, list(work.items()), chunksize=1)
    pool.close()
    signal.signal(signal.SIGINT, original_sigint_handler)

    try:
        for result in tqdm(results, total=len(list(work.items()))):
            pass
    except KeyboardInterrupt:
        print("Caught Ctrl+C; shutting pool down gracefully")
        pool.terminate()
        return
    pool.join()


def search_region(args):
    region_path, region_work = args
    for chunk_x, chunk_z, section_index in region_work:
        region = anvil.Region.from_file(region_path)
        try:
            chunk = region.get_chunk(chunk_x, chunk_z)
            for block in chunk.stream_blocks(section=section_index):
                if block.namespace != 'mekanism':
                    continue
                # if block.id.endswith('_ore') or block.id == "block_salt":
                #     continue
                if block.id != 'digital_miner':
                    continue
                print(f'{chunk_x}, {chunk_z}: {block.namespace}:{block.id}')
        except anvil.errors.ChunkNotFound as e:
            pass


if __name__ == '__main__':
    main()
