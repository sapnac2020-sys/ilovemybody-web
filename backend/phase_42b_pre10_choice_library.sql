-- Phase 42B: complete response library for PRE-10 discovery assessments
-- Target: u756742628_ilovemybody
-- Prerequisite: Phase 42. Safe to rerun.
-- Choices are prompts, not findings. "Something else" and "prefer not" remain
-- available so the interface never forces a person into our wording.

START TRANSACTION;

INSERT INTO `ilb_pre10_option`
 (`item_id`,`option_key`,`option_order`,`option_text`,`numeric_value`,`meaning_note`)
SELECT i.`item_id`,x.`option_key`,x.`option_order`,x.`option_text`,NULL,x.`meaning_note`
FROM `ilb_pre10_item` i
JOIN (
 SELECT 'current_reality' a,'reason_here' q,'understand_health' k,10 n,'I want to understand my health or body' t,NULL m
 UNION ALL SELECT 'current_reality','reason_here','preventive',20,'I want to care for myself preventively',NULL
 UNION ALL SELECT 'current_reality','reason_here','ongoing_illness',30,'I am living with an ongoing illness',NULL
 UNION ALL SELECT 'current_reality','reason_here','recovery',40,'I am recovering from an operation or treatment',NULL
 UNION ALL SELECT 'current_reality','reason_here','life_clarity',50,'I want greater clarity about my life',NULL
 UNION ALL SELECT 'current_reality','hardest_now','body',10,'Something in my body',NULL
 UNION ALL SELECT 'current_reality','hardest_now','thoughts',20,'My thoughts or mental load',NULL
 UNION ALL SELECT 'current_reality','hardest_now','feelings',30,'My feelings',NULL
 UNION ALL SELECT 'current_reality','hardest_now','relationship',40,'A relationship or loneliness',NULL
 UNION ALL SELECT 'current_reality','hardest_now','direction',50,'Work, purpose or direction',NULL
 UNION ALL SELECT 'current_reality','understand_now','patterns',10,'My patterns',NULL
 UNION ALL SELECT 'current_reality','understand_now','body_signals',20,'What my body may be communicating',NULL
 UNION ALL SELECT 'current_reality','understand_now','choices',30,'How my choices affect me',NULL
 UNION ALL SELECT 'current_reality','understand_now','feelings',40,'My feelings and needs',NULL
 UNION ALL SELECT 'current_reality','understand_now','direction',50,'What I truly want',NULL
 UNION ALL SELECT 'current_reality','present_words','calm',10,'Calm',NULL
 UNION ALL SELECT 'current_reality','present_words','hopeful',20,'Hopeful',NULL
 UNION ALL SELECT 'current_reality','present_words','tired',30,'Tired',NULL
 UNION ALL SELECT 'current_reality','present_words','worried',40,'Worried',NULL
 UNION ALL SELECT 'current_reality','present_words','confused',50,'Confused',NULL
 UNION ALL SELECT 'current_reality','present_words','ready',60,'Ready',NULL
 UNION ALL SELECT 'current_reality','support_now','self',10,'Myself',NULL
 UNION ALL SELECT 'current_reality','support_now','family',20,'Family',NULL
 UNION ALL SELECT 'current_reality','support_now','friend',30,'A friend',NULL
 UNION ALL SELECT 'current_reality','support_now','professional',40,'A professional',NULL
 UNION ALL SELECT 'current_reality','support_now','practice',50,'A practice, faith or community',NULL

 UNION ALL SELECT 'thought_patterns','mind_returns','health',10,'Health or my body',NULL
 UNION ALL SELECT 'thought_patterns','mind_returns','relationships',20,'Relationships',NULL
 UNION ALL SELECT 'thought_patterns','mind_returns','work_money',30,'Work or money',NULL
 UNION ALL SELECT 'thought_patterns','mind_returns','past',40,'Something from the past',NULL
 UNION ALL SELECT 'thought_patterns','mind_returns','future',50,'What may happen next',NULL
 UNION ALL SELECT 'thought_patterns','decision_style','facts',10,'Facts and practical details',NULL
 UNION ALL SELECT 'thought_patterns','decision_style','feelings',20,'My feelings',NULL
 UNION ALL SELECT 'thought_patterns','decision_style','body_signal',30,'A body feeling or instinct',NULL
 UNION ALL SELECT 'thought_patterns','decision_style','others',40,'What other people may think or need',NULL
 UNION ALL SELECT 'thought_patterns','decision_style','risk',50,'Possible risks',NULL

 UNION ALL SELECT 'beliefs_body','body_belief','ally',10,'My body is my ally',NULL
 UNION ALL SELECT 'beliefs_body','body_belief','responsibility',20,'My body is my responsibility',NULL
 UNION ALL SELECT 'beliefs_body','body_belief','unfamiliar',30,'My body sometimes feels unfamiliar',NULL
 UNION ALL SELECT 'beliefs_body','body_belief','judged',40,'I often judge my body',NULL
 UNION ALL SELECT 'beliefs_body','body_belief','discovering',50,'I am still discovering my relationship with my body',NULL
 UNION ALL SELECT 'beliefs_body','health_belief','medical',10,'Medical care and medicines',NULL
 UNION ALL SELECT 'beliefs_body','health_belief','daily_choices',20,'Daily choices and routines',NULL
 UNION ALL SELECT 'beliefs_body','health_belief','food',30,'Food and digestion',NULL
 UNION ALL SELECT 'beliefs_body','health_belief','mind_emotion',40,'Thoughts, beliefs and feelings',NULL
 UNION ALL SELECT 'beliefs_body','health_belief','relationships_environment',50,'Relationships and environment',NULL
 UNION ALL SELECT 'beliefs_body','health_belief','many_connected',60,'Many connected influences',NULL

 UNION ALL SELECT 'feelings_expression','feelings_present','joy',10,'Joy',NULL
 UNION ALL SELECT 'feelings_expression','feelings_present','calm',20,'Calm',NULL
 UNION ALL SELECT 'feelings_expression','feelings_present','fear',30,'Fear',NULL
 UNION ALL SELECT 'feelings_expression','feelings_present','anger',40,'Anger',NULL
 UNION ALL SELECT 'feelings_expression','feelings_present','sadness',50,'Sadness',NULL
 UNION ALL SELECT 'feelings_expression','feelings_present','guilt',60,'Guilt',NULL
 UNION ALL SELECT 'feelings_expression','feelings_present','shame',70,'Shame',NULL
 UNION ALL SELECT 'feelings_expression','feelings_present','numb',80,'Numbness',NULL
 UNION ALL SELECT 'feelings_expression','feeling_location','head',10,'Head or face',NULL
 UNION ALL SELECT 'feelings_expression','feeling_location','throat',20,'Throat',NULL
 UNION ALL SELECT 'feelings_expression','feeling_location','chest',30,'Chest',NULL
 UNION ALL SELECT 'feelings_expression','feeling_location','gut',40,'Stomach or gut',NULL
 UNION ALL SELECT 'feelings_expression','feeling_location','whole_body',50,'Across my body',NULL
 UNION ALL SELECT 'feelings_expression','expression_style','express',10,'I express it',NULL
 UNION ALL SELECT 'feelings_expression','expression_style','pause',20,'I pause and stay with it',NULL
 UNION ALL SELECT 'feelings_expression','expression_style','hide',30,'I hide or suppress it',NULL
 UNION ALL SELECT 'feelings_expression','expression_style','distract',40,'I distract myself',NULL
 UNION ALL SELECT 'feelings_expression','expression_style','react',50,'I react before I understand it',NULL
 UNION ALL SELECT 'feelings_expression','safe_feelings','myself',10,'With myself',NULL
 UNION ALL SELECT 'feelings_expression','safe_feelings','partner',20,'With a partner',NULL
 UNION ALL SELECT 'feelings_expression','safe_feelings','family_friend',30,'With family or a friend',NULL
 UNION ALL SELECT 'feelings_expression','safe_feelings','professional',40,'With a professional',NULL
 UNION ALL SELECT 'feelings_expression','safe_feelings','no_one_yet',50,'With no one yet',NULL
 UNION ALL SELECT 'feelings_expression','difficult_feeling','anger',10,'Anger',NULL
 UNION ALL SELECT 'feelings_expression','difficult_feeling','sadness',20,'Sadness',NULL
 UNION ALL SELECT 'feelings_expression','difficult_feeling','fear',30,'Fear',NULL
 UNION ALL SELECT 'feelings_expression','difficult_feeling','need',40,'Need or vulnerability',NULL
 UNION ALL SELECT 'feelings_expression','difficult_feeling','joy',50,'Joy or excitement',NULL
 UNION ALL SELECT 'feelings_expression','wanted_feeling','calm',10,'Calm',NULL
 UNION ALL SELECT 'feelings_expression','wanted_feeling','joy',20,'Joy',NULL
 UNION ALL SELECT 'feelings_expression','wanted_feeling','confidence',30,'Confidence',NULL
 UNION ALL SELECT 'feelings_expression','wanted_feeling','connection',40,'Connection',NULL
 UNION ALL SELECT 'feelings_expression','wanted_feeling','freedom',50,'Freedom',NULL

 UNION ALL SELECT 'body_relationship','body_words','loving',10,'Loving',NULL
 UNION ALL SELECT 'body_relationship','body_words','grateful',20,'Grateful',NULL
 UNION ALL SELECT 'body_relationship','body_words','curious',30,'Curious',NULL
 UNION ALL SELECT 'body_relationship','body_words','critical',40,'Critical',NULL
 UNION ALL SELECT 'body_relationship','body_words','distant',50,'Distant',NULL
 UNION ALL SELECT 'body_relationship','body_words','conflicted',60,'Conflicted',NULL
 UNION ALL SELECT 'body_relationship','body_judgement','function',10,'What my body enables me to do',NULL
 UNION ALL SELECT 'body_relationship','body_judgement','comfort',20,'How my body feels',NULL
 UNION ALL SELECT 'body_relationship','body_judgement','appearance',30,'How my body looks',NULL
 UNION ALL SELECT 'body_relationship','body_judgement','pain_signal',40,'Pain or another signal',NULL
 UNION ALL SELECT 'body_relationship','body_judgement','whole',50,'My body as a whole',NULL
 UNION ALL SELECT 'body_relationship','body_signals','notice_respond',10,'I notice and respond',NULL
 UNION ALL SELECT 'body_relationship','body_signals','notice_wait',20,'I notice and wait',NULL
 UNION ALL SELECT 'body_relationship','body_signals','ignore',30,'I often ignore it',NULL
 UNION ALL SELECT 'body_relationship','body_signals','worry',40,'I become worried',NULL
 UNION ALL SELECT 'body_relationship','body_signals','seek_help',50,'I seek suitable help',NULL
 UNION ALL SELECT 'body_relationship','body_need','rest',10,'Rest or sleep',NULL
 UNION ALL SELECT 'body_relationship','body_need','movement',20,'Movement',NULL
 UNION ALL SELECT 'body_relationship','body_need','food_water',30,'Food or water',NULL
 UNION ALL SELECT 'body_relationship','body_need','comfort_touch',40,'Comfort or touch',NULL
 UNION ALL SELECT 'body_relationship','body_need','expression',50,'Expression or release',NULL
 UNION ALL SELECT 'body_relationship','body_need','medical_attention',60,'Medical attention',NULL

 UNION ALL SELECT 'values_alignment','values_select','love',10,'Love',NULL
 UNION ALL SELECT 'values_alignment','values_select','freedom',20,'Freedom',NULL
 UNION ALL SELECT 'values_alignment','values_select','honesty',30,'Honesty',NULL
 UNION ALL SELECT 'values_alignment','values_select','family',40,'Family',NULL
 UNION ALL SELECT 'values_alignment','values_select','health',50,'Health',NULL
 UNION ALL SELECT 'values_alignment','values_select','creativity',60,'Creativity',NULL
 UNION ALL SELECT 'values_alignment','values_select','learning',70,'Learning',NULL
 UNION ALL SELECT 'values_alignment','values_select','contribution',80,'Contribution',NULL
 UNION ALL SELECT 'values_alignment','value_choice','love',10,'What feels loving',NULL
 UNION ALL SELECT 'values_alignment','value_choice','fear',20,'What feels safest',NULL
 UNION ALL SELECT 'values_alignment','value_choice','duty',30,'Duty or responsibility',NULL
 UNION ALL SELECT 'values_alignment','value_choice','belonging',40,'Belonging or approval',NULL
 UNION ALL SELECT 'values_alignment','value_choice','practical',50,'Practical reality',NULL

 UNION ALL SELECT 'lifestyle_comfort','day_rhythm','spacious',10,'Spacious and manageable',NULL
 UNION ALL SELECT 'lifestyle_comfort','day_rhythm','full',20,'Full but manageable',NULL
 UNION ALL SELECT 'lifestyle_comfort','day_rhythm','rushed',30,'Rushed',NULL
 UNION ALL SELECT 'lifestyle_comfort','day_rhythm','unpredictable',40,'Unpredictable',NULL
 UNION ALL SELECT 'lifestyle_comfort','day_rhythm','flat',50,'Flat or repetitive',NULL
 UNION ALL SELECT 'lifestyle_comfort','rest_sleep','restorative',10,'Restorative',NULL
 UNION ALL SELECT 'lifestyle_comfort','rest_sleep','variable',20,'Variable',NULL
 UNION ALL SELECT 'lifestyle_comfort','rest_sleep','insufficient',30,'Often insufficient',NULL
 UNION ALL SELECT 'lifestyle_comfort','rest_sleep','interrupted',40,'Often interrupted',NULL
 UNION ALL SELECT 'lifestyle_comfort','self_care','bath_brush',10,'Bathing and brushing',NULL
 UNION ALL SELECT 'lifestyle_comfort','self_care','clean_clothes',20,'Clean, comfortable clothes',NULL
 UNION ALL SELECT 'lifestyle_comfort','self_care','rest',30,'Rest',NULL
 UNION ALL SELECT 'lifestyle_comfort','self_care','movement',40,'Movement',NULL
 UNION ALL SELECT 'lifestyle_comfort','self_care','personal_space',50,'Caring for my personal space',NULL
 UNION ALL SELECT 'lifestyle_comfort','comfort_zone','failure',10,'Failure or disappointment',NULL
 UNION ALL SELECT 'lifestyle_comfort','comfort_zone','judgement',20,'Judgment or rejection',NULL
 UNION ALL SELECT 'lifestyle_comfort','comfort_zone','uncertainty',30,'Uncertainty',NULL
 UNION ALL SELECT 'lifestyle_comfort','comfort_zone','conflict',40,'Conflict',NULL
 UNION ALL SELECT 'lifestyle_comfort','comfort_zone','effort',50,'Effort or discomfort',NULL
 UNION ALL SELECT 'lifestyle_comfort','automatic_choice','food',10,'Food or drink',NULL
 UNION ALL SELECT 'lifestyle_comfort','automatic_choice','phone',20,'Phone or digital use',NULL
 UNION ALL SELECT 'lifestyle_comfort','automatic_choice','work',30,'Work',NULL
 UNION ALL SELECT 'lifestyle_comfort','automatic_choice','substance',40,'Smoking, alcohol or another substance',NULL
 UNION ALL SELECT 'lifestyle_comfort','automatic_choice','avoidance',50,'Avoiding something difficult',NULL
 UNION ALL SELECT 'lifestyle_comfort','environment_effect','noise',10,'Noise',NULL
 UNION ALL SELECT 'lifestyle_comfort','environment_effect','light',20,'Light',NULL
 UNION ALL SELECT 'lifestyle_comfort','environment_effect','clutter',30,'Clutter or cleanliness',NULL
 UNION ALL SELECT 'lifestyle_comfort','environment_effect','people',40,'People around me',NULL
 UNION ALL SELECT 'lifestyle_comfort','environment_effect','nature',50,'Nature or open space',NULL

 UNION ALL SELECT 'relationships_belonging','relationship_feel','supportive',10,'Supportive',NULL
 UNION ALL SELECT 'relationships_belonging','relationship_feel','loving',20,'Loving',NULL
 UNION ALL SELECT 'relationships_belonging','relationship_feel','demanding',30,'Demanding',NULL
 UNION ALL SELECT 'relationships_belonging','relationship_feel','distant',40,'Distant',NULL
 UNION ALL SELECT 'relationships_belonging','relationship_feel','unsafe',50,'Unsafe',NULL
 UNION ALL SELECT 'relationships_belonging','relationship_feel','mixed',60,'Mixed or changing',NULL
 UNION ALL SELECT 'relationships_belonging','belonging_place','home',10,'At home',NULL
 UNION ALL SELECT 'relationships_belonging','belonging_place','friend_family',20,'With family or friends',NULL
 UNION ALL SELECT 'relationships_belonging','belonging_place','work',30,'At work',NULL
 UNION ALL SELECT 'relationships_belonging','belonging_place','community',40,'In a community or faith space',NULL
 UNION ALL SELECT 'relationships_belonging','belonging_place','alone',50,'When I am alone',NULL
 UNION ALL SELECT 'relationships_belonging','belonging_place','nowhere_yet',60,'Nowhere at present',NULL

 UNION ALL SELECT 'intimacy_desire','closeness_meaning','emotional',10,'Emotional openness',NULL
 UNION ALL SELECT 'intimacy_desire','closeness_meaning','affection',20,'Affection and touch',NULL
 UNION ALL SELECT 'intimacy_desire','closeness_meaning','sexual',30,'Sexual connection',NULL
 UNION ALL SELECT 'intimacy_desire','closeness_meaning','trust',40,'Trust and safety',NULL
 UNION ALL SELECT 'intimacy_desire','closeness_meaning','companionship',50,'Companionship',NULL

 UNION ALL SELECT 'dreams_direction','work_energy','design_make',10,'Designing or making',NULL
 UNION ALL SELECT 'dreams_direction','work_energy','solve',20,'Solving problems',NULL
 UNION ALL SELECT 'dreams_direction','work_energy','teach_help',30,'Teaching or helping',NULL
 UNION ALL SELECT 'dreams_direction','work_energy','lead_build',40,'Leading or building',NULL
 UNION ALL SELECT 'dreams_direction','work_energy','perform_express',50,'Performing or expressing',NULL
 UNION ALL SELECT 'dreams_direction','work_energy','learn_explore',60,'Learning or exploring',NULL
 UNION ALL SELECT 'dreams_direction','dream_constraint','fear',10,'Fear',NULL
 UNION ALL SELECT 'dreams_direction','dream_constraint','money',20,'Money or resources',NULL
 UNION ALL SELECT 'dreams_direction','dream_constraint','time',30,'Time or responsibilities',NULL
 UNION ALL SELECT 'dreams_direction','dream_constraint','skill',40,'Skills or experience',NULL
 UNION ALL SELECT 'dreams_direction','dream_constraint','support',50,'Support or permission',NULL
 UNION ALL SELECT 'dreams_direction','dream_constraint','clarity',60,'Clarity about the next step',NULL

 UNION ALL SELECT 'courage_selftrust','instinct_signal','body',10,'A body sensation',NULL
 UNION ALL SELECT 'courage_selftrust','instinct_signal','feeling',20,'A feeling',NULL
 UNION ALL SELECT 'courage_selftrust','instinct_signal','thought',30,'A recurring thought',NULL
 UNION ALL SELECT 'courage_selftrust','instinct_signal','image_dream',40,'An image or dream',NULL
 UNION ALL SELECT 'courage_selftrust','instinct_signal','knowing',50,'A quiet sense of knowing',NULL
 UNION ALL SELECT 'courage_selftrust','fear_response','pause',10,'Pause and notice',NULL
 UNION ALL SELECT 'courage_selftrust','fear_response','avoid',20,'Avoid or postpone',NULL
 UNION ALL SELECT 'courage_selftrust','fear_response','prepare',30,'Prepare or gather information',NULL
 UNION ALL SELECT 'courage_selftrust','fear_response','seek_support',40,'Seek support',NULL
 UNION ALL SELECT 'courage_selftrust','fear_response','act',50,'Act despite fear',NULL
 UNION ALL SELECT 'courage_selftrust','confidence_source','experience',10,'Past experience',NULL
 UNION ALL SELECT 'courage_selftrust','confidence_source','preparation',20,'Preparation or knowledge',NULL
 UNION ALL SELECT 'courage_selftrust','confidence_source','support',30,'Encouragement or support',NULL
 UNION ALL SELECT 'courage_selftrust','confidence_source','instinct',40,'Trusting my instinct',NULL
 UNION ALL SELECT 'courage_selftrust','confidence_source','action',50,'Taking a first small action',NULL

 UNION ALL SELECT 'complete_clarity','priority_choose','body_medical',10,'My body and medical picture',NULL
 UNION ALL SELECT 'complete_clarity','priority_choose','thoughts_beliefs',20,'Thoughts and beliefs',NULL
 UNION ALL SELECT 'complete_clarity','priority_choose','feelings',30,'Feelings and expression',NULL
 UNION ALL SELECT 'complete_clarity','priority_choose','lifestyle',40,'Lifestyle and choices',NULL
 UNION ALL SELECT 'complete_clarity','priority_choose','relationships',50,'Relationships and intimacy',NULL
 UNION ALL SELECT 'complete_clarity','priority_choose','direction',60,'Dreams and direction',NULL
 UNION ALL SELECT 'complete_clarity','map_words','cluttered',10,'Cluttered',NULL
 UNION ALL SELECT 'complete_clarity','map_words','confused',20,'Confused',NULL
 UNION ALL SELECT 'complete_clarity','map_words','comfortable',30,'Comfortable',NULL
 UNION ALL SELECT 'complete_clarity','map_words','cleaner',40,'Cleaner',NULL
 UNION ALL SELECT 'complete_clarity','map_words','clearer',50,'Clearer',NULL
 UNION ALL SELECT 'complete_clarity','map_words','ready',60,'Ready to explore',NULL
) x ON x.a=i.`assessment_key` AND x.q=i.`item_key`
WHERE NOT EXISTS (
 SELECT 1 FROM `ilb_pre10_option` o
 WHERE o.`item_id`=i.`item_id` AND o.`option_key`=x.k
);

-- All native choices preserve an open answer and a privacy boundary.
INSERT INTO `ilb_pre10_option`
 (`item_id`,`option_key`,`option_order`,`option_text`,`numeric_value`,`meaning_note`)
SELECT i.`item_id`,'other',900,'Something else',NULL,'The participant may add their own words.'
FROM `ilb_pre10_item` i
WHERE i.`response_type` IN ('single_choice','multi_choice')
AND NOT EXISTS (
 SELECT 1 FROM `ilb_pre10_option` o WHERE o.`item_id`=i.`item_id` AND o.`option_key`='other'
);

INSERT INTO `ilb_pre10_option`
 (`item_id`,`option_key`,`option_order`,`option_text`,`numeric_value`,`meaning_note`)
SELECT i.`item_id`,'prefer_not',999,'I prefer not to answer',NULL,'A valid boundary; never treated as missing cooperation.'
FROM `ilb_pre10_item` i
WHERE i.`response_type` IN ('single_choice','multi_choice')
AND NOT EXISTS (
 SELECT 1 FROM `ilb_pre10_option` o WHERE o.`item_id`=i.`item_id` AND o.`option_key`='prefer_not'
);

-- value_lived and value_gap reuse exactly the values selected earlier.
-- The frontend must constrain them to the participant's own values_select response.

COMMIT;

SELECT
 COUNT(*) AS `choice_items`,
 SUM(CASE WHEN NOT EXISTS (
   SELECT 1 FROM `ilb_pre10_option` o WHERE o.`item_id`=i.`item_id`
 ) THEN 1 ELSE 0 END) AS `choice_items_without_options`
FROM `ilb_pre10_item` i
WHERE i.`response_type` IN ('single_choice','multi_choice','yes_no_unsure');

