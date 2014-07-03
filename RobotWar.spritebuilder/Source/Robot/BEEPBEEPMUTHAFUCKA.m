//
//  BEEPBEEPMUTHAFUCKA.m
//  RobotWar
//
//  Created by Thomas Lam on 7/1/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "BEEPBEEPMUTHAFUCKA.h"

typedef NS_ENUM(NSInteger, RobotState) {
    Default,
    Shooting,
    Turn,
    Reverse
};

static BOOL reverse = TRUE;
static int numHit = 0;

@implementation BEEPBEEPMUTHAFUCKA {
    RobotState _currentRobotState;
    CGPoint _lastKnownPosition;
    CGFloat _lastHitTimeStamp;
    CGFloat _lastDetectedTimeStamp;
}

- (void)run {
    while(true) {
        if (_currentRobotState == Default || (self.currentTimestamp - _lastHitTimeStamp > 3.f && self.currentTimestamp - _lastDetectedTimeStamp > 3.f)) {
            [self moveAhead:300];
        }
        
        if (_currentRobotState == Shooting) {
            [self turnGunTowardsEnemy];
            [self shoot];
        }
    }
}

- (void)hitWall:(RobotWallHitDirection)hitDirection hitAngle:(CGFloat)hitAngle {
    [self cancelActiveAction];
    _currentRobotState = Turn;
    
    switch (hitDirection) {
        case RobotWallHitDirectionFront:
            [self turnRobotRight:90];
            [self moveAhead:100];
            break;
        case RobotWallHitDirectionRear:
            [self turnRobotLeft:90];
            [self moveAhead:100];
            break;
        default:
            break;
    }
    _currentRobotState = Default;
}

- (void)scannedRobot:(Robot *)robot atPosition:(CGPoint)position {
    if (_currentRobotState != Shooting) {
        [self cancelActiveAction];
    }
    
    _lastKnownPosition = position;
    _lastDetectedTimeStamp = self.currentTimestamp;
    _currentRobotState = Shooting;
}

- (void) bulletHitEnemy:(Bullet *)bullet {
    _lastHitTimeStamp = self.currentTimestamp;
}

- (void) gotHit {
    numHit++;
    if (numHit % 3 == 0) {
        [self cancelActiveAction];
        reverse = !reverse;
        _currentRobotState = Reverse;
        if (reverse) {
            [self moveBack:300];
        } else {
            [self moveAhead:300];
        }
        _currentRobotState = Default;
    }
}

- (void) turnGunTowardsEnemy {
    CGFloat angle = [self angleBetweenGunHeadingDirectionAndWorldPosition:_lastKnownPosition];
    if (angle >= 0) {
        [self turnGunRight:abs(angle)];
    } else {
        [self turnGunLeft:abs(angle)];
    }
}

@end
