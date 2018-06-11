#!/bin/bash

set -x

fn create route videobox --format json --type async --timeout 3600 --idle-timeout 10 --memory 1000 /frame-splitter $FN_REGISTRY/frame-splitter:0.0.32
fn config routes videobox /frame-splitter NEXT_FUNC /object-detect

fn create route videobox --format json --type async --timeout 3000 --idle-timeout 30 --memory 400 /object-detect $FN_REGISTRY/object_detect:0.0.10
fn config route videobox /object-detect DETECT_PRECISION 0.4
fn config route videobox /object-detect NEXT_FUNC /segment-assembler

fn create route videobox --format json --type async --timeout 30 --idle-timeout 20 --memory 400 /segment-assembler $FN_REGISTRY/segment-assembler:0.0.20

fn create route videobox --format json --type async --timeout 50 --idle-timeout 10 --memory 256 /bucket-daemon $FN_REGISTRY/bucket-daemon:0.0.4
fn config route videobox /bucket-daemon NEXT_FUNC /segments-assembler
fn config route videobox /bucket-daemon BACKOFF_TIME 5

fn create route videobox --format json --type async --timeout 3600 --idle-timeout 20 --memory 512 /segments-assembler $FN_REGISTRY/segments-assembler:0.0.5
fn config route videobox /segments-assembler NEXT_FUNC /bucket-cleaner

fn create route videobox  --format json --type async --timeout 360 --idle-timeout 10 --memory 256 /bucket-cleaner $FN_REGISTRY/bucket-cleaner:0.0.4 
