package  {
	
	public class Tween3d {

		public function Tween3d() {
			// constructor code
		}

	}
	
}

/*
//
//  Tween2Manager.cpp
//  CasaCasinoCore
//
//  Created by Yonny Zohar on 18/02/2020.
//  Copyright © 2020 Ofer Rundstein. All rights reserved.
//

#include "TweeningSystem.h"
#include "shaker/TransformComponentManager.h"
#include "shaker/IdComponentManager.h"

//should this be here?!?!?!
#include "script/ScriptContext.h"
#include "Curve.h"
#include "MathUtil.h"
#include "RuntimeInsight/RuntimeInsight.h"

CTweeningSystem::CTweeningSystem()
{
    foundation::Allocator& allocator = foundation::memory_globals::default_allocator();
    m_tween3dPool.init(MAX_NUM_TWEENS, &allocator);
    
    foundation::Allocator& allocator1 = foundation::memory_globals::default_allocator();
    m_tweenParamsPool.init(MAX_NUM_TWEENS, &allocator1);
    m_currTweensCount = 0;
    m_currCallbacksCount = 0;
    m_currPendingCount = 0;
}

shaker::DataItemId CTweeningSystem::add3dTween(shaker::World world, shaker::Entity ent, LuaCallbackData lcd, TweenInitParams p)
{
    
    SHAKER_ASSERT(m_currPendingCount < MAX_NUM_TWEENS);
    
    if(m_worldManager == NULL)
    {
        m_worldManager = GET_WORLD_MANAGER;
    }
    
    Tween3d& tween = m_tween3dPool.alloc();
    tween.world = world;
    tween.ent = ent;
    
    if(lcd.updateCallbackRef != -1 || lcd.completeCallbackRef != -1)
    {
        ScriptContext* scriptContext = ScriptContext::getMyScriptContext(lcd.state);
        lcd.controller = scriptContext->getScriptController();
    }
    
    tween.lcd = lcd;
    
    //go to the pool and get params obj
    TweenParams& params = m_tweenParamsPool.alloc();
    //get current id for access both tween and params (should be identical!)
    shaker::DataItemId id  = m_tweenParamsPool.getID(params);
    
    params.duration = p.duration;
    params.delay = p.delay;
    
    if(params.delay > 0)
    {
        params.isInDelay = true;
    }
    else
    {
        params.isInDelay = false;
    }
    
    params.currDelayTime = 0;
    params.easeFunction = p.easingFnc;
    params.fnctnType = tweenTypes::LINEAR;
    params.numPosVariables = 0;
    params.rotationTween = false;
    params.translateTween = false;
    params.twoCtrlPoints = false;
    params.scaleTween = false;
    params.lookAtTween = false;
    
    if(p.gotLookAt)
    {
        params.lookAtTween = true;
        params.lookAtX = p.lookAtPos.x;
        params.lookAtY = p.lookAtPos.y;
        params.lookAtZ = p.lookAtPos.z;
        params.worldUp = p.worldUp;
        params.lType = p.lType;
    }
    
    if(p.gotScale)
    {
        params.scaleTween = true;
        params.scaleStartVals[0] = p.startScale.x;
        params.scaleDestValues[0] = p.destScale.x;
        params.scaleRangeValues[0] = p.destScale.x - p.startScale.x;
        
        params.scaleStartVals[1] = p.startScale.y;
        params.scaleDestValues[1] = p.destScale.y;
        params.scaleRangeValues[1] = p.destScale.y - p.startScale.y;
        
        params.scaleStartVals[2] = p.startScale.z;
        params.scaleDestValues[2] = p.destScale.z;
        params.scaleRangeValues[2] = p.destScale.z - p.startScale.z;
        params.numScaleVariables = 3;//x,y,z
    }
    
    if(p.gotDest)
    {
        params.translateTween = true;
        params.posStartVals[0] = p.startPos.x;
        params.posDestValues[0] = p.endPos.x;
        params.posRangeValues[0] = p.endPos.x - p.startPos.x;;
        
        params.posStartVals[1] = p.startPos.y;
        params.posDestValues[1] = p.endPos.y;
        params.posRangeValues[1] = p.endPos.y - p.startPos.y;
        
        params.posStartVals[2] = p.startPos.z;
        params.posDestValues[2] = p.endPos.z;
        params.posRangeValues[2] = p.endPos.z - p.startPos.z;
        params.numPosVariables = 3;//x,y,z
        
        if(p.gotCtrl1 || p.gotCtrl2)
        {
            params.fnctnType = tweenTypes::BEZIER;
            params.posCtrlVals[0] = p.ctrl1Pos.x;
            params.posCtrlVals[1] = p.ctrl1Pos.y;
            params.posCtrlVals[2] = p.ctrl1Pos.z;
            
            if(p.gotCtrl2)
            {
                params.posCtrl2Vals[0] = p.ctrl2Pos.x;
                params.posCtrl2Vals[1] = p.ctrl2Pos.y;
                params.posCtrl2Vals[2] = p.ctrl2Pos.z;
                params.twoCtrlPoints = true;
            }
        }
    }
    
    
    if(p.gotRotation)
    {
        if(params.lookAtTween == true)
        {
            LOG_ERROR("Can't have rotate and look at in same tween!");
            SHAKER_ASSERT(false);
        }
        
        params.rotStartVals[0]   = p.startRot.x;
        params.rotDestValues[0]  = p.destRot.x;
        
        params.rotStartVals[1]   = p.startRot.y;
        params.rotDestValues[1]  = p.destRot.y;
        
        params.rotStartVals[2]   = p.startRot.z;
        params.rotDestValues[2]  = p.destRot.z;
        
        params.rotStartVals[3]   = p.startRot.w;
        params.rotDestValues[3]  = p.destRot.w;
        
        params.rotationTween = true; //x,y,z,w
    }
    
    params.isComplete = false; //resetting is super important
    params.isKilled = false;
    params.currTime = 0; //resetting is super important
    
    
    m_pendingTweens[m_currPendingCount] = id;
    m_currPendingCount++;
    
    return id;
    
}




Our update function is split into parts:
 -----------
 1.get all pending tweens added since last run and add to active list
 2.go over active tweens and get current value in relation to easing function at current time
 3.calculate actual rotation / scale / postion in tween
 4.update entity translation
 5.remove tweens pending deletion
 6.call lua callbacks
 


void CTweeningSystem::update(ShakerTime elapsedTime)
{
    RUNTIME_INSIGHT_REPORT_SCOPE(CTweeningSystem_update);

    int i = 0;
    for(i = 0; i < m_currPendingCount; i++)
    {
        shaker::DataItemId id = m_pendingTweens[i];
        TweenParams& params = m_tweenParamsPool.get(id);
        params.indexInActiveList = m_currTweensCount;//get the current index in active list, this is for removing the object later
        m_activeTweens[m_currTweensCount] = id;
        m_currTweensCount++;
        //LOG("adding tween %i currPendingCount %i", id, currPendingCount);
    }
    
    //LOG("update tween currTweensCount %i ", currTweensCount);
    
    m_currPendingCount = 0;

    
    //advance time
    for(i = 0; i < m_currTweensCount; i++)
    {
        //////////////////////////////////////////////////////////--GET_TWEEN_OBJ--///////////////////////////////////////////////////////////
        shaker::DataItemId id = m_activeTweens[i];
        TweenParams& params = m_tweenParamsPool.get(id);
       // Tween3d& tween      = m_tween3dPool.get(id);
        
        
        if(params.isInDelay)
        {
            params.currDelayTime += elapsedTime;
            if(params.currDelayTime >= params.delay)
            {
                params.isInDelay = false;
            }
        }
        //if this tween is in delay, don't update its time
        if(!params.isInDelay)
        {
            //////////////////////////////////////////////////////////--UPDATE TIME--///////////////////////////////////////////////////////////
            params.currTime += elapsedTime;
            
            // duration is already in milliseconds
            if (params.currTime >= params.duration)
            {
                params.currTime = params.duration;
                // tween is about to complete
                //LOG("completed tween %i currTweensCount %i", id, currTweensCount);
                params.isComplete = true;
                m_pendingDeletionTweens[m_currPendingDeletion] = id;
                m_currPendingDeletion++;
            }
        }
    }
    
    
    //get easing and update function values
    for(i = 0; i < m_currTweensCount; i++)
    {
        //////////////////////////////////////////////////////////--GET_TWEEN_OBJ--///////////////////////////////////////////////////////////
        shaker::DataItemId id = m_activeTweens[i];
        TweenParams& params = m_tweenParamsPool.get(id);
       // Tween3d& tween      = m_tween3dPool.get(id);
        
        //if this tween is in delay, don't update its easing or values
        if(params.isInDelay)
        {
            continue;
        }

        /////////////////////////////////////////----GET_CURRENT_EASE_PERCENTAGE----//////////////////////////////////////
        
        //this is a value between 0 and 1 which we can later pass to our function ( linier/ bezier/ slerp )
        float easePercent = params.easeFunction(params.currTime, 0, 1, params.duration);
        
               
        //////////////////////////////////////////////////////////--SET_VALUES_BY_TWEEN_TYPE--///////////////////////////////////////////////////////////
        
        if(params.scaleTween == true)
        {
            for (unsigned int j = 0; j < params.numScaleVariables; j++)
            {
                //this is a linear function which takes in the ease as percent
                params.scaleCurrentValues[j] = (params.scaleRangeValues[j] * easePercent) + params.scaleStartVals[j];
            }
        }
        
        
        if(params.rotationTween == true)
        {
            bx::quatSlerp(
                params.rotStartVals[0],
                params.rotStartVals[1],
                params.rotStartVals[2],
                params.rotStartVals[3],
                
                params.rotDestValues[0],
                params.rotDestValues[1],
                params.rotDestValues[2],
                params.rotDestValues[3],
                  
                easePercent,
                  
                &params.rotCurrentValues[0],
                &params.rotCurrentValues[1],
                &params.rotCurrentValues[2],
                &params.rotCurrentValues[3]
            );
        }
        
        
        
        if(params.translateTween == true)
        {
            //find generic way to do this
            if(params.fnctnType == tweenTypes::LINEAR)
            {
                for (unsigned int j = 0; j < params.numPosVariables; j++)
                {
                    //this is a linear function which takes in the ease as percent
                    params.posCurrentValues[j] = (params.posRangeValues[j] * easePercent) + params.posStartVals[j];
                }
            }
            else if(params.fnctnType == tweenTypes::BEZIER)
            {
                if(!params.twoCtrlPoints)
                {
                    //this is a standard Quadratic Bézier curve
                    for (unsigned int j = 0; j < params.numPosVariables; j++)
                    {
                        //curve
                        params.posCurrentValues[j] = (1-easePercent)*(1-easePercent)*params.posStartVals[j] + 2*(1-easePercent)*easePercent*params.posCtrlVals[j] + easePercent*easePercent*params.posDestValues[j];
                        
                        //derivitive:
                        params.posDerivitiveValues[j] = 2 * (1-easePercent) * (params.posCtrlVals[j] - params.posStartVals[j]) + (easePercent*easePercent) * (params.posDestValues[j] - params.posCtrlVals[j]);
                    }
                }
                else
                {
                    
                    //this is a standard Cubic Bézier curve
                    for (unsigned int j = 0; j < params.numPosVariables; j++)
                    {
                        //curve
                        params.posCurrentValues[j] = (1-easePercent)*(1-easePercent)*(1-easePercent)*params.posStartVals[j] + 3*(1-easePercent)*(1-easePercent)*easePercent*params.posCtrlVals[j] + 3*(1-easePercent)*(easePercent*easePercent)*params.posCtrl2Vals[j] + easePercent*easePercent*easePercent*params.posDestValues[j];
                        
                        //derivitive:
                        params.posDerivitiveValues[j] = 3 * ((1-easePercent)*(1-easePercent))*(params.posCtrlVals[j]-params.posStartVals[j]) + 6 * (1-easePercent) * easePercent * (params.posCtrl2Vals[j] - params.posCtrlVals[j]) + 3 * (easePercent*easePercent) * (params.posDestValues[j] - params.posCtrl2Vals[j]);
                    }
                }
            }
        }
    }
    
    //////////////////////////////////////////////////////////--UPDATE_ACTUAL_ENTITY--//////////////////////////////////////////////////////////////////////////
    for(i = 0; i < m_currTweensCount; i++)
    {
        shaker::DataItemId id = m_activeTweens[i];
        TweenParams& params = m_tweenParamsPool.get(id);
        Tween3d& tween = m_tween3dPool.get(id);
        
        //if this tween is in delay, don't update its translation
        if(params.isInDelay)
        {
            continue;
        }
        
        void* worldImpl = NULL;
        uint32_t worldFlags;
        m_worldManager->getWorldImplementation(tween.world, &worldImpl, &worldFlags);
        if (worldImpl)
        {
            shaker::TransformComponentManager* transformManager = ((shaker::World3D*)worldImpl)->m_transformManager;
            shaker::TransformComponentManager::Instance inst = transformManager->lookup(tween.ent);
            if (inst.isValid())
            {
                if(params.translateTween == true)
                {
                    shaker::Vector3 position;
                    position.x = params.posCurrentValues[0];//x
                    position.y = params.posCurrentValues[1];//y
                    position.z = params.posCurrentValues[2];//z
                    transformManager->setPositionWithoutWorldUpdate(inst, position);
                }
                
                if(params.rotationTween == true)
                {
                    shaker::Quaternion rotation;
                    rotation.x = params.rotCurrentValues[0];//x
                    rotation.y = params.rotCurrentValues[1];//y
                    rotation.z = params.rotCurrentValues[2];//z
                    rotation.w = params.rotCurrentValues[3];//w
                    transformManager->setRotationWithoutWorldUpdate(inst, rotation);
                                        
                }
                else if(params.lookAtTween == true)
                {
                    shaker::Vector3 position;
                    position.x = params.posCurrentValues[0];//x
                    position.y = params.posCurrentValues[1];//y
                    position.z = params.posCurrentValues[2];//z
                    
                    shaker::Vector3 forward;
                    shaker::Vector3 destPosition;
                    
                    if(params.lType == lookAtTypes::POINT)
                    {
                        destPosition.x = params.lookAtX;
                        destPosition.y = params.lookAtY;
                        destPosition.z = params.lookAtZ;
                        //get the forward vector by subtracting the destination from the current entity
                        bx::vec3Sub(forward.val, destPosition.val, position.val);
                    }
                    else
                    {
                        //if this is a bezeir tween use the derivitive of the curve
                        if(params.fnctnType == tweenTypes::BEZIER)
                        {
                            forward.x = params.posDerivitiveValues[0];
                            forward.y = params.posDerivitiveValues[1];
                            forward.z = params.posDerivitiveValues[2];
                        }
                        else
                        {
                            
                            //if this is a linear tween just look at the destination
                            destPosition.x = params.lookAtX;
                            destPosition.y = params.lookAtY;
                            destPosition.z = params.lookAtZ;
                            //get the forward vector by subtracting the destination from the current entity
                            bx::vec3Sub(forward.val, destPosition.val, position.val);
                            
                            //after doing this once there is no need to do it anymore,
                            //this is a linear path
                            params.lookAtTween = false;
                            
                            
                        }
                    }
                    
                    //call the look at with the forward vector and the direction vector
                    shaker::Quaternion rotation;
                    bx::quatLookAt(rotation.val, forward.val, params.worldUp.val);
                    
                    transformManager->setRotationWithoutWorldUpdate(inst, rotation);
                }
                
                if(params.scaleTween == true)
                {
                    shaker::Vector3 scale;
                    scale.x = params.scaleCurrentValues[0];//x
                    scale.y = params.scaleCurrentValues[1];//y
                    scale.z = params.scaleCurrentValues[2];//z
                    transformManager->setScaleWithoutWorldUpdate(inst, scale);
                }
                transformManager->updateWorldTransform(inst.i);
            }
            else
            {
                LOG_ERROR("CTween2Manager - Failed to find entity in transform component! %d", tween.ent.id);
            }
        }
        else
        {
            LOG_ERROR("CTween2Manager - Failed to find world in transform component! %d", tween.world.id);
        }
    }
    
    //remove compeleted or killed tweens
    for(i = 0; i < m_currPendingDeletion; i++)
    {
        //////////////////////////////////////////////////////////--GET_TWEEN_OBJ--///////////////////////////////////////////////////////////
        shaker::DataItemId id = m_pendingDeletionTweens[i];
        TweenParams& params = m_tweenParamsPool.get(id);
        Tween3d& tween      = m_tween3dPool.get(id);
        
        //////////////////////////////////////////////////////////--KILL_COMPLETE_TWEEN--//////////////////////////////////////////////////////////////////////////
        //if our tween is complete we need to remove it from our active list
        //return it to the pool
        //then take the last element in the list and place it in the current slot
        //set i back one to encounter it in the loop in the next run
        
        m_tweenParamsPool.free(params);
        m_tween3dPool.free(tween);
        
        //take the last tween in the active list and move it to fill the hole we just created after killing / ending the current tween
        shaker::DataItemId lastId = m_activeTweens[m_currTweensCount-1];
        TweenParams& lastParams = m_tweenParamsPool.get(lastId);
        
        m_activeTweens[params.indexInActiveList] = lastId;
        lastParams.indexInActiveList = params.indexInActiveList;
        m_currTweensCount--;
        
        
        //if this is a valid completiong not a brute kill
        if(!params.isKilled)
        {
             //if lua callback defined
            if(tween.lcd.completeCallbackRef != -1)
            {
                tween.lcd.controller->executeFunction<void>(tween.lcd.completeSelfRef, tween.lcd.completeCallbackRef, false, "p", tween.ent);
            }
        }
    }
    m_currPendingDeletion = 0;
    
    //send update callback after romving completed instances
    for(i = 0; i < m_currTweensCount; i++)
    {
        shaker::DataItemId id = m_activeTweens[i];
        TweenParams& params = m_tweenParamsPool.get(id);
        Tween3d& tween      = m_tween3dPool.get(id);
        
        if(tween.lcd.updateCallbackRef != -1)
        {
            tween.lcd.controller->executeFunction<void>(tween.lcd.updateSelfRef, tween.lcd.updateCallbackRef, true, "pf", tween.ent, (params.currTime / params.duration));
        }
    }
}


//will mark tween for killing
void CTweeningSystem::killTween(shaker::DataItemId tweenId)
{
    TweenParams* params = m_tweenParamsPool.tryToGet(tweenId);
    if(params != NULL)
    {
        params->isKilled = true;
        m_pendingDeletionTweens[m_currPendingDeletion] = tweenId;
        m_currPendingDeletion++;
    }
}


*/