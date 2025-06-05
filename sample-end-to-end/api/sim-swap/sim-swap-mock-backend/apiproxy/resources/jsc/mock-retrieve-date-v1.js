/**
 * Copyright 2025 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

var rand = Math.random() *100;
print(rand);

context.setVariable("response.header.content-type", "application/json");

var payload = {latestSimChange: ""};
var currentDate = new Date();
var isoDate = currentDate.toISOString();

 if (rand < 50 ) {
     payload.latestSimChange = isoDate;
     
 } else {
    payload.latestSimChange = "2023-12-12T07:34:58.382Z";
 }
 
 context.setVariable('response.content', JSON.stringify(payload));
