-- CS4400: Introduction to Database Systems: Monday, March 3, 2025
-- Simple Airline Management System Course Project Mechanics [TEMPLATE] (v0)
-- Views, Functions & Stored Procedures

/* This is a standard preamble for most of our scripts.  The intent is to establish
a consistent environment for the database behavior. */
set global transaction isolation level serializable;
set global SQL_MODE = 'ANSI,TRADITIONAL';
set names utf8mb4;
set SQL_SAFE_UPDATES = 0;

set @thisDatabase = 'flight_tracking';
use flight_tracking;
-- -----------------------------------------------------------------------------
-- stored procedures and views
-- -----------------------------------------------------------------------------
/* Standard Procedure: If one or more of the necessary conditions for a procedure to
be executed is false, then simply have the procedure halt execution without changing
the database state. Do NOT display any error messages, etc. */

-- [_] supporting functions, views and stored procedures
-- -----------------------------------------------------------------------------
/* Helpful library capabilities to simplify the implementation of the required
views and procedures. */
-- -----------------------------------------------------------------------------
drop function if exists leg_time;
delimiter //
create function leg_time (ip_distance integer, ip_speed integer)
	returns time reads sql data
begin
	declare total_time decimal(10,2);
    declare hours, minutes integer default 0;
    set total_time = ip_distance / ip_speed;
    set hours = truncate(total_time, 0);
    set minutes = truncate((total_time - hours) * 60, 0);
    return maketime(hours, minutes, 0);
end //
delimiter ;

-- [1] add_airplane()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new airplane.  A new airplane must be sponsored
by an existing airline, and must have a unique tail number for that airline.
username.  An airplane must also have a non-zero seat capacity and speed. An airplane
might also have other factors depending on it's type, like the model and the engine.  
Finally, an airplane must have a new and database-wide unique location
since it will be used to carry passengers. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_airplane;
delimiter //
create procedure add_airplane (in ip_airlineID varchar(50), in ip_tail_num varchar(50),
	in ip_seat_capacity integer, in ip_speed integer, in ip_locationID varchar(50),
    in ip_plane_type varchar(100), in ip_maintenanced boolean, in ip_model varchar(50),
    in ip_neo boolean)
sp_main: begin

	-- Ensure that the plane type is valid: Boeing, Airbus, or neither
    -- Ensure that the type-specific attributes are accurate for the type
    -- Ensure that the airplane and location values are new and unique
    -- Add airplane and location into respective tables
    
	IF NOT EXISTS (SELECT 1 FROM airline WHERE airlineID = ip_airlineID)
	   OR EXISTS (SELECT 1 FROM airplane WHERE airlineID = ip_airlineID AND tail_num = ip_tail_num)
	   OR ip_seat_capacity <= 0 
	   OR ip_speed <= 0 THEN
		  LEAVE sp_main;
	END IF;

	IF ip_locationID IS NOT NULL THEN
	   IF EXISTS (SELECT 1 FROM location WHERE locationID = ip_locationID) THEN
		   LEAVE sp_main;
	   ELSE
		   INSERT INTO location (locationID) VALUES (ip_locationID);
	   END IF;
	END IF;

	INSERT INTO airplane 
		 (airlineID, tail_num, seat_capacity, speed, locationID, plane_type, maintenanced, model, neo)
	VALUES 
		 (ip_airlineID, ip_tail_num, ip_seat_capacity, ip_speed, ip_locationID, ip_plane_type, ip_maintenanced, CAST(ip_model AS CHAR), ip_neo);

end //
delimiter ;

-- [2] add_airport()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new airport.  A new airport must have a unique
identifier along with a new and database-wide unique location if it will be used
to support airplane takeoffs and landings.  An airport may have a longer, more
descriptive name.  An airport must also have a city, state, and country designation. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_airport;
delimiter //
create procedure add_airport (in ip_airportID char(3), in ip_airport_name varchar(200),
    in ip_city varchar(100), in ip_state varchar(100), in ip_country char(3), in ip_locationID varchar(50))
sp_main: begin

	-- Ensure that the airport and location values are new and unique
    -- Add airport and location into respective tables
    
    IF EXISTS (
        SELECT 1 FROM airport WHERE airportID = ip_airportID
        UNION
        SELECT 1 FROM location WHERE locationID = ip_locationID
    ) THEN
        LEAVE sp_main;
    END IF;
    
    INSERT INTO location (locationID) VALUES (ip_locationID);
    INSERT INTO airport (airportID, airport_name, city, state, country, locationID)
    VALUES (ip_airportID, ip_airport_name, ip_city, ip_state, ip_country, ip_locationID);
    
end //
delimiter ;


-- [3] add_person()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new person.  A new person must reference a unique
identifier along with a database-wide unique location used to determine where the
person is currently located: either at an airport, or on an airplane, at any given
time.  A person must have a first name, and might also have a last name.

A person can hold a pilot role or a passenger role (exclusively).  As a pilot,
a person must have a tax identifier to receive pay, and an experience level.  As a
passenger, a person will have some amount of frequent flyer miles, along with a
certain amount of funds needed to purchase tickets for flights. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_person;
delimiter //
create procedure add_person (in ip_personID varchar(50), in ip_first_name varchar(100),
    in ip_last_name varchar(100), in ip_locationID varchar(50), in ip_taxID varchar(50),
    in ip_experience integer, in ip_miles integer, in ip_funds integer)
sp_main: begin

	-- Ensure that the location is valid
    -- Ensure that the persion ID is unique
    -- Ensure that the person is a pilot or passenger
    -- Add them to the person table as well as the table of their respective role
    -- 1. Check that the provided location exists.
    IF NOT EXISTS (SELECT 1 FROM location WHERE locationID = ip_locationID)
       OR EXISTS (SELECT 1 FROM person WHERE personID = ip_personID)
       OR ip_first_name IS NULL OR TRIM(ip_first_name) = '' THEN
         LEAVE sp_main;
    END IF;
    
    IF ( (ip_taxID IS NOT NULL OR ip_experience IS NOT NULL) 
         AND (ip_miles IS NOT NULL OR ip_funds IS NOT NULL) ) THEN
         LEAVE sp_main;
    END IF;

    IF (ip_taxID IS NOT NULL OR ip_experience IS NOT NULL) THEN
         IF ip_taxID IS NULL OR TRIM(ip_taxID) = '' OR ip_experience IS NULL THEN
              LEAVE sp_main;
         END IF;
         INSERT INTO person (personID, first_name, last_name, locationID)
         VALUES (ip_personID, ip_first_name, ip_last_name, ip_locationID);
         
         INSERT INTO pilot (personID, taxID, experience, commanding_flight)
         VALUES (ip_personID, ip_taxID, ip_experience, NULL);
         
    ELSEIF (ip_miles IS NOT NULL OR ip_funds IS NOT NULL) THEN
         IF ip_miles IS NULL OR ip_funds IS NULL THEN
              LEAVE sp_main;
         END IF;

         INSERT INTO person (personID, first_name, last_name, locationID)
         VALUES (ip_personID, ip_first_name, ip_last_name, ip_locationID);
         
         INSERT INTO passenger (personID, miles, funds)
         VALUES (ip_personID, ip_miles, ip_funds);
    ELSE
         LEAVE sp_main;
    END IF;

end //
delimiter ;

-- [4] grant_or_revoke_pilot_license()
-- -----------------------------------------------------------------------------
/* This stored procedure inverts the status of a pilot license.  If the license
doesn't exist, it must be created; and, if it aready exists, then it must be removed. */
-- -----------------------------------------------------------------------------
drop procedure if exists grant_or_revoke_pilot_license;
delimiter //
create procedure grant_or_revoke_pilot_license (in ip_personID varchar(50), in ip_license varchar(100))
sp_main: begin

	-- Ensure that the person is a valid pilot
    -- If license exists, delete it, otherwise add the license
    DECLARE license_exists BOOLEAN;

    IF NOT EXISTS (SELECT 1 FROM pilot WHERE personID = ip_personID) THEN
        LEAVE sp_main;
    END IF;

    SELECT EXISTS (SELECT 1 FROM pilot_licenses WHERE personID = ip_personID AND license = ip_license) INTO license_exists;

    IF license_exists THEN
        DELETE FROM pilot_licenses WHERE personID = ip_personID AND license = ip_license;
    ELSE
        INSERT INTO pilot_licenses (personID, license) VALUES (ip_personID, ip_license);
    END IF;
    
end //
delimiter ;

-- [5] offer_flight()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new flight.  The flight can be defined before
an airplane has been assigned for support, but it must have a valid route.  And
the airplane, if designated, must not be in use by another flight.  The flight
can be started at any valid location along the route except for the final stop,
and it will begin on the ground.  You must also include when the flight will
takeoff along with its cost. */
-- -----------------------------------------------------------------------------
drop procedure if exists offer_flight;
delimiter //
create procedure offer_flight (in ip_flightID varchar(50), in ip_routeID varchar(50),
    in ip_support_airline varchar(50), in ip_support_tail varchar(50), in ip_progress integer,
    in ip_next_time time, in ip_cost integer)
sp_main: begin

	-- Ensure that the airplane exists
    -- Ensure that the route exists
    -- Ensure that the progress is less than the length of the route
    -- Create the flight with the airplane starting in on the ground
    -- 1. Ensure that the specified route exists.
    
    IF NOT EXISTS (SELECT 1 FROM route WHERE routeID = ip_routeID)
       OR ip_progress >= (SELECT COUNT(*) FROM route_path WHERE routeID = ip_routeID)
    THEN
         LEAVE sp_main;
    END IF;
    
    IF ip_support_airline IS NOT NULL AND ip_support_tail IS NOT NULL THEN
         IF NOT EXISTS (
              SELECT 1 FROM airplane 
              WHERE airlineID = ip_support_airline 
                AND tail_num = ip_support_tail
         ) THEN
              LEAVE sp_main;
         END IF;
         
         IF EXISTS (
              SELECT 1 FROM flight 
              WHERE support_airline = ip_support_airline 
                AND support_tail = ip_support_tail
         ) THEN
              LEAVE sp_main;
         END IF;
    END IF;
    
    INSERT INTO flight (
         flightID, 
         routeID, 
         support_airline, 
         support_tail, 
         progress, 
         airplane_status, 
         next_time, 
         cost
    )
    VALUES (
         ip_flightID, 
         ip_routeID, 
         ip_support_airline, 
         ip_support_tail, 
         ip_progress, 
         'on_ground', 
         ip_next_time, 
         ip_cost
    );

end //
delimiter ;

-- [6] flight_landing()
-- -----------------------------------------------------------------------------
/* This stored procedure updates the state for a flight landing at the next airport
along it's route.  The time for the flight should be moved one hour into the future
to allow for the flight to be checked, refueled, restocked, etc. for the next leg
of travel.  Also, the pilots of the flight should receive increased experience, and
the passengers should have their frequent flyer miles updated. */
-- -----------------------------------------------------------------------------
drop procedure if exists flight_landing;
delimiter //
create procedure flight_landing (in ip_flightID varchar(50))
sp_main: begin

	-- Ensure that the flight exists
    -- Ensure that the flight is in the air
    
    -- Increment the pilot's experience by 1
    -- Increment the frequent flyer miles of all passengers on the plane
    -- Update the status of the flight and increment the next time to 1 hour later
		-- Hint: use addtime()
        
	DECLARE rID VARCHAR(50);
    DECLARE seq INT;
    DECLARE dist INT;
    DECLARE aid VARCHAR(50);
    DECLARE tail VARCHAR(50);
    DECLARE loc VARCHAR(50);

    IF NOT EXISTS (
        SELECT 1 FROM flight WHERE flightID = ip_flightID
    ) OR (
        SELECT airplane_status FROM flight WHERE flightID = ip_flightID
    ) != 'in_flight' THEN
        LEAVE sp_main;
    END IF;

    SELECT routeID, progress, support_airline, support_tail
    INTO rID, seq, aid, tail
    FROM flight WHERE flightID = ip_flightID;

    SELECT l.distance INTO dist
    FROM route_path routePath
    JOIN leg l ON routePath.legID = l.legID
    WHERE routePath.routeID = rID AND routePath.sequence = seq;

    SELECT locationID INTO loc
    FROM airplane
    WHERE airlineID = aid AND tail_num = tail;

    UPDATE pilot
    SET experience = experience + 1
    WHERE commanding_flight = ip_flightID;

    UPDATE passenger p
    JOIN person pe ON p.personID = pe.personID
    SET p.miles = p.miles + dist
    WHERE pe.locationID = loc;

    UPDATE flight
    SET airplane_status = 'on_ground', next_time = ADDTIME(next_time, '01:00:00')
    WHERE flightID = ip_flightID;
end //
delimiter ;


-- [7] flight_takeoff()
-- -----------------------------------------------------------------------------
/* This stored procedure updates the state for a flight taking off from its current
airport towards the next airport along it's route.  The time for the next leg of
the flight must be calculated based on the distance and the speed of the airplane.
And we must also ensure that Airbus and general planes have at least one pilot
assigned, while Boeing must have a minimum of two pilots. If the flight cannot take
off because of a pilot shortage, then the flight must be delayed for 30 minutes. */
-- -----------------------------------------------------------------------------
drop procedure if exists flight_takeoff;
delimiter //
create procedure flight_takeoff (in ip_flightID varchar(50))
sp_main: begin

	-- Ensure that the flight exists
    -- Ensure that the flight is on the ground
    -- Ensure that the flight has another leg to fly
    -- Ensure that there are enough pilots (1 for Airbus and general, 2 for Boeing)
		-- If there are not enough, move next time to 30 minutes later
        
	-- Increment the progress and set the status to in flight
    -- Calculate the flight time using the speed of airplane and distance of leg
    -- Update the next time using the flight time
     -- Declare variables to hold flight, airplane, and leg details.
    -- Declare variables for flight, airplane, and leg details.
    DECLARE v_status VARCHAR(50);
    DECLARE v_routeID VARCHAR(50);
    DECLARE v_progress INT;
    DECLARE v_next_time TIME;
    DECLARE v_support_airline VARCHAR(50);
    DECLARE v_support_tail VARCHAR(50);
    DECLARE v_total_legs INT;
    DECLARE v_airplane_type VARCHAR(100);
    DECLARE v_speed INT;
    DECLARE v_required_pilots INT;
    DECLARE v_assigned_pilots INT;
    DECLARE v_leg_distance INT;
    DECLARE v_flight_time TIME;
    
    SELECT airplane_status, routeID, progress, next_time, support_airline, support_tail
      INTO v_status, v_routeID, v_progress, v_next_time, v_support_airline, v_support_tail
      FROM flight
      WHERE flightID = ip_flightID;
      
    IF v_status IS NULL THEN
         LEAVE sp_main;
    END IF;
    
    IF v_status <> 'on_ground' THEN
         SIGNAL SQLSTATE '45000' 
             SET MESSAGE_TEXT = 'Flight is not on the ground.';
    END IF;
    
    SELECT COUNT(*) INTO v_total_legs 
      FROM route_path 
      WHERE routeID = v_routeID;
      
    IF v_progress >= v_total_legs THEN
         SIGNAL SQLSTATE '45000'
             SET MESSAGE_TEXT = 'No more legs available for this flight.';
    END IF;
    
    SELECT plane_type, speed 
      INTO v_airplane_type, v_speed
      FROM airplane
      WHERE airlineID = v_support_airline AND tail_num = v_support_tail;
      
    IF v_airplane_type = 'Boeing' THEN
         SET v_required_pilots = 2;
    ELSE
         SET v_required_pilots = 1;
    END IF;
    
    SELECT COUNT(*) INTO v_assigned_pilots 
      FROM pilot 
      WHERE commanding_flight = ip_flightID;
      
    IF v_assigned_pilots < v_required_pilots THEN
         UPDATE flight 
            SET next_time = ADDTIME(next_time, '00:30:00')
         WHERE flightID = ip_flightID;
         SIGNAL SQLSTATE '45000' 
             SET MESSAGE_TEXT = 'Not enough pilots assigned. Flight delayed by 30 minutes.';
    END IF;
    
    SET v_progress = v_progress + 1;
    UPDATE flight
       SET progress = v_progress,
           airplane_status = 'in_flight'
     WHERE flightID = ip_flightID;
     
    SELECT l.distance
      INTO v_leg_distance
      FROM route_path rp
      JOIN leg l ON rp.legID = l.legID
      WHERE rp.routeID = v_routeID AND rp.sequence = v_progress;
      
    SET v_flight_time = SEC_TO_TIME(v_leg_distance * 3600 / v_speed);
    
    UPDATE flight
       SET next_time = ADDTIME(next_time, v_flight_time)
     WHERE flightID = ip_flightID;

end //
delimiter ;

-- [8] passengers_board()
-- -----------------------------------------------------------------------------
/* This stored procedure updates the state for passengers getting on a flight at
its current airport.  The passengers must be at the same airport as the flight,
and the flight must be heading towards that passenger's desired destination.
Also, each passenger must have enough funds to cover the flight.  Finally, there
must be enough seats to accommodate all boarding passengers. */
-- -----------------------------------------------------------------------------
drop procedure if exists passengers_board;
delimiter //
create procedure passengers_board (in ip_flightID varchar(50))
sp_main: begin

	-- Ensure the flight exists
    -- Ensure that the flight is on the ground
    -- Ensure that the flight has further legs to be flown
    
    -- Determine the number of passengers attempting to board the flight
    -- Use the following to check:
		-- The airport the airplane is currently located at
        -- The passengers are located at that airport
        -- The passenger's immediate next destination matches that of the flight
        -- The passenger has enough funds to afford the flight
        
	-- Check if there enough seats for all the passengers
		-- If not, do not add board any passengers
        -- If there are, board them and deduct their funds
        
	DECLARE flight_status VARCHAR(50);
    DECLARE route_id VARCHAR(50);
    DECLARE current_leg INT;
    DECLARE scheduled_time TIME;
    DECLARE flight_cost INT;
    DECLARE airline_id VARCHAR(50);
    DECLARE tail_number VARCHAR(50);
    
    DECLARE total_legs INT;
    DECLARE airport_location_id VARCHAR(50);
    DECLARE next_airport_id VARCHAR(50);
    DECLARE eligible_passenger_count INT;
    DECLARE airplane_capacity INT;
    DECLARE onboard_passenger_count INT;
    DECLARE airplane_location_id VARCHAR(50);
    DECLARE current_airport_id CHAR(3);

    SELECT airplane_status, routeID, progress, next_time, cost, support_airline, support_tail
    INTO flight_status, route_id, current_leg, scheduled_time, flight_cost, airline_id, tail_number
    FROM flight
    WHERE flightID = ip_flightID;
    
    SELECT COUNT(*) INTO total_legs FROM route_path WHERE routeID = route_id;

    IF flight_status IS NULL OR flight_status <> 'on_ground' or current_leg >= total_legs THEN
        LEAVE sp_main;
    END IF;

    SELECT IF(current_leg = 0, l.departure, l.arrival)
    INTO current_airport_id
    FROM route_path rp JOIN leg l ON rp.legID = l.legID
    WHERE rp.routeID = route_id AND rp.sequence = IF(current_leg = 0, 1, current_leg);

    SELECT locationID INTO airport_location_id FROM airport WHERE airportID = current_airport_id;

    SELECT l.arrival INTO next_airport_id
    FROM route_path routePath JOIN leg l ON routePath.legID = l.legID
    WHERE routePath.routeID = route_id AND routePath.sequence = current_leg + 1;

    SELECT seat_capacity, locationID
    INTO airplane_capacity, airplane_location_id
    FROM airplane
    WHERE airlineID = airline_id AND tail_num = tail_number;

    SELECT COUNT(*) INTO onboard_passenger_count
    FROM person
    WHERE locationID = airplane_location_id AND personID IN (SELECT personID FROM passenger);

    SELECT COUNT(DISTINCT pe.personID) INTO eligible_passenger_count
    FROM person pe
    JOIN passenger p ON pe.personID = p.personID
    JOIN passenger_vacations pv ON pe.personID = pv.personID
    WHERE pe.locationID = airport_location_id
      AND pv.airportID = next_airport_id
      AND pv.sequence = 1
      AND p.funds >= flight_cost;

    IF (onboard_passenger_count + eligible_passenger_count) > airplane_capacity THEN
        LEAVE sp_main;
    END IF;

    UPDATE passenger p
    JOIN person pe ON p.personID = pe.personID
    JOIN passenger_vacations pv ON pe.personID = pv.personID
    SET p.funds = p.funds - flight_cost,
        pe.locationID = airplane_location_id
    WHERE pe.locationID = airport_location_id
      AND pv.airportID = next_airport_id
      AND pv.sequence = 1
      AND p.funds >= flight_cost;
      
end  //
delimiter ;

-- [9] passengers_disembark()
-- -----------------------------------------------------------------------------
/* This stored procedure updates the state for passengers getting off of a flight
at its current airport.  The passengers must be on that flight, and the flight must
be located at the destination airport as referenced by the ticket. */
-- -----------------------------------------------------------------------------
drop procedure if exists passengers_disembark;
delimiter //
create procedure passengers_disembark (in ip_flightID varchar(50))
sp_main: begin
	DECLARE v_status VARCHAR(50);
    DECLARE v_routeID VARCHAR(50);
    DECLARE v_progress INT;
    DECLARE v_next_time TIME;
    DECLARE v_flight_cost INT;
    DECLARE v_support_airline VARCHAR(50);
    DECLARE v_support_tail VARCHAR(50);
    DECLARE v_temp_airport_id CHAR(3);
    DECLARE v_airport_location VARCHAR(50);
    DECLARE v_airplane_location VARCHAR(50);

    SELECT airplane_status, routeID, progress, next_time, cost, support_airline, support_tail
      INTO v_status, v_routeID, v_progress, v_next_time, v_flight_cost, v_support_airline, v_support_tail
      FROM flight
      WHERE flightID = ip_flightID;
    
    IF v_status IS NULL OR v_status <> 'on_ground' THEN
         LEAVE sp_main;
    END IF;
    
    SELECT l.arrival 
      INTO v_temp_airport_id
      FROM route_path rp
      JOIN leg l ON rp.legID = l.legID
      WHERE rp.routeID = v_routeID AND rp.sequence = v_progress;
    
    SELECT locationID 
      INTO v_airport_location
      FROM airport
      WHERE airportID = v_temp_airport_id;
    
    SELECT locationID 
      INTO v_airplane_location
      FROM airplane
      WHERE airlineID = v_support_airline AND tail_num = v_support_tail;
    
    UPDATE person p
      JOIN passenger pa ON p.personID = pa.personID
      JOIN passenger_vacations pv ON p.personID = pv.personID
      SET p.locationID = v_airport_location
      WHERE p.locationID = v_airplane_location
        AND pv.airportID = v_temp_airport_id
        AND pv.sequence = 1;
    
	CREATE TEMPORARY TABLE temp_pids (personID VARCHAR(50));

	INSERT INTO temp_pids
	SELECT DISTINCT pa.personID
	  FROM passenger pa
	  JOIN passenger_vacations pv2
		ON pa.personID = pv2.personID
	 WHERE pv2.airportID = v_temp_airport_id;

	UPDATE passenger_vacations AS pv
	JOIN person             AS p  ON p.personID = pv.personID
	JOIN temp_pids          AS t  ON t.personID = pv.personID
	SET pv.sequence = pv.sequence - 1
	WHERE p.locationID = v_airport_location
    AND pv.sequence > 1;

	DROP TEMPORARY TABLE temp_pids;
    
    DELETE FROM passenger_vacations
     WHERE sequence <= 0;
end//
delimeter;


-- [10] assign_pilot()
-- -----------------------------------------------------------------------------
/* This stored procedure assigns a pilot as part of the flight crew for a given
flight.  The pilot being assigned must have a license for that type of airplane,
and must be at the same location as the flight.  Also, a pilot can only support
one flight (i.e. one airplane) at a time.  The pilot must be assigned to the flight
and have their location updated for the appropriate airplane. */
-- -----------------------------------------------------------------------------
drop procedure if exists assign_pilot;
delimiter //
create procedure assign_pilot (in ip_flightID varchar(50), ip_personID varchar(50))
sp_main: begin

	-- Ensure the flight exists
    -- Ensure that the flight is on the ground
    -- Ensure that the flight has further legs to be flown
    
    -- Ensure that the pilot exists and is not already assigned
	-- Ensure that the pilot has the appropriate license
    -- Ensure the pilot is located at the airport of the plane that is supporting the flight
    
    -- Assign the pilot to the flight and update their location to be on the plane
    
     -- Declare variables to hold flight and airplane details.
    -- Declare variables to hold flight details and airplane info.
    -- Declare descriptive variable names for flight and airplane details
    DECLARE flight_status VARCHAR(50);
    DECLARE route_id VARCHAR(50);
    DECLARE flight_progress INT;
    DECLARE total_legs INT;
    DECLARE airline_id VARCHAR(50);
    DECLARE tail_number VARCHAR(50);
    DECLARE airplane_type VARCHAR(100);
    DECLARE airplane_location_id VARCHAR(50); 
    DECLARE current_airport_id CHAR(3);
    DECLARE airport_location_id VARCHAR(50);
    DECLARE pilot_location_id VARCHAR(50);

    IF NOT EXISTS (SELECT 1 FROM flight WHERE flightID = ip_flightID) THEN
        LEAVE sp_main;
    END IF;

    SELECT airplane_status, routeID, progress, support_airline, support_tail
    INTO flight_status, route_id, flight_progress, airline_id, tail_number
    FROM flight
    WHERE flightID = ip_flightID;

    IF flight_status <> 'on_ground' THEN
        LEAVE sp_main;
    END IF;

    SELECT plane_type, locationID
    INTO airplane_type, airplane_location_id
    FROM airplane
    WHERE airlineID = airline_id AND tail_num = tail_number;

    SELECT COUNT(*) INTO total_legs
    FROM route_path
    WHERE routeID = route_id;

    IF flight_progress >= total_legs
       OR NOT EXISTS (SELECT 1 FROM pilot WHERE personID = ip_personID)
       OR EXISTS (SELECT 1 FROM pilot WHERE personID = ip_personID AND commanding_flight IS NOT NULL) 
       OR NOT EXISTS (SELECT 1 FROM pilot_licenses WHERE personID = ip_personID AND license = airplane_type) THEN
        LEAVE sp_main;
    END IF;

    IF flight_progress = 0 THEN
        SELECT l.departure
        INTO current_airport_id
        FROM route_path rp
        JOIN leg l ON rp.legID = l.legID
        WHERE rp.routeID = route_id AND rp.sequence = 1;
    ELSE
        SELECT l.arrival
        INTO current_airport_id
        FROM route_path rp
        JOIN leg l ON rp.legID = l.legID
        WHERE rp.routeID = route_id AND rp.sequence = flight_progress;
    END IF;

    SELECT locationID
    INTO airport_location_id
    FROM airport
    WHERE airportID = current_airport_id;

    SELECT locationID
    INTO pilot_location_id
    FROM person
    WHERE personID = ip_personID;

    IF pilot_location_id <> airport_location_id THEN
        LEAVE sp_main;
    END IF;

    UPDATE pilot
    SET commanding_flight = ip_flightID
    WHERE personID = ip_personID;

    UPDATE person
    SET locationID = airplane_location_id
    WHERE personID = ip_personID;
    
end //
delimiter ;

-- [11] recycle_crew()
-- -----------------------------------------------------------------------------
/* This stored procedure releases the assignments for a given flight crew.  The
flight must have ended, and all passengers must have disembarked. */
-- -----------------------------------------------------------------------------
drop procedure if exists recycle_crew;
delimiter //
create procedure recycle_crew (in ip_flightID varchar(50))
sp_main: begin
DECLARE airport_location VARCHAR(50);
    DECLARE flight_status VARCHAR(100);
    DECLARE route_progress INT;
    DECLARE route_max_sequence INT;
    DECLARE plane_airline VARCHAR(50);
    DECLARE plane_tail VARCHAR(50);
    DECLARE plane_location VARCHAR(50);

    IF NOT EXISTS (SELECT 1 FROM flight WHERE flightID = ip_flightID) THEN
         LEAVE sp_main;
    END IF;

    SELECT airplane_status, progress, support_airline, support_tail
      INTO flight_status, route_progress, plane_airline, plane_tail
      FROM flight
      WHERE flightID = ip_flightID;

    IF plane_airline IS NULL OR plane_tail IS NULL THEN
         LEAVE sp_main;
    END IF;

    SELECT locationID 
      INTO plane_location
      FROM airplane
      WHERE airlineID = plane_airline AND tail_num = plane_tail;

    SELECT a.locationID
      INTO airport_location
      FROM flight f
      JOIN route_path rp 
        ON f.routeID = rp.routeID AND rp.sequence = route_progress
      JOIN leg l 
        ON rp.legID = l.legID
      JOIN airport a 
        ON l.arrival = a.airportID
      WHERE f.flightID = ip_flightID;

    IF flight_status <> 'on_ground' THEN
         LEAVE sp_main;
    END IF;

    SELECT MAX(sequence)
      INTO route_max_sequence
      FROM route_path
      WHERE routeID = (SELECT routeID FROM flight WHERE flightID = ip_flightID);

    IF route_progress < route_max_sequence THEN
         LEAVE sp_main;
    END IF;

    IF EXISTS (
         SELECT 1 
         FROM person p
         JOIN passenger pas ON p.personID = pas.personID
         WHERE p.locationID = plane_location
    ) THEN
         LEAVE sp_main;
    END IF;

    UPDATE person
      SET locationID = airport_location
      WHERE personID IN (
            SELECT personID 
            FROM pilot 
            WHERE commanding_flight = ip_flightID
      );

    UPDATE pilot
      SET commanding_flight = NULL
      WHERE commanding_flight = ip_flightID;
    
end //
delimiter ;


-- [12] retire_flight()
-- -----------------------------------------------------------------------------
/* This stored procedure removes a flight that has ended from the system.  The
flight must be on the ground, and either be at the start its route, or at the
end of its route.  And the flight must be empty - no pilots or passengers. */
-- -----------------------------------------------------------------------------
drop procedure if exists retire_flight;
delimiter //
CREATE PROCEDURE retire_flight (IN ip_flightID VARCHAR(50))
sp_main: BEGIN
   
    DECLARE flight_status VARCHAR(50);
    DECLARE route_id VARCHAR(50);
    DECLARE progress INT;
    DECLARE total_legs INT;
    DECLARE airline_id VARCHAR(50);
    DECLARE tail_number VARCHAR(50);
    DECLARE airport_id CHAR(3);
    DECLARE airport_location_id VARCHAR(50);

    IF NOT EXISTS (SELECT 1 FROM flight WHERE flightID = ip_flightID) THEN
        LEAVE sp_main;
    END IF;

    SELECT airplane_status, routeID, progress, support_airline, support_tail
    INTO flight_status, route_id, progress, airline_id, tail_number
    FROM flight WHERE flightID = ip_flightID;
    
    SELECT COUNT(*) INTO total_legs FROM route_path WHERE routeID = route_id;

    IF flight_status != 'on_ground' or NOT (progress = 0 OR progress = total_legs) or EXISTS (SELECT 1 FROM pilot WHERE commanding_flight = ip_flightID) THEN
        LEAVE sp_main;
    END IF;

    SELECT IF(progress = 0, l.departure, l.arrival)
    INTO airport_id
    FROM route_path rp
    JOIN leg l ON rp.legID = l.legID
    WHERE rp.routeID = route_id AND rp.sequence = IF(progress = 0, 1, total_legs);

    SELECT locationID INTO airport_location_id FROM airport WHERE airportID = airport_id;

    IF EXISTS (SELECT 1 FROM person JOIN passenger ON person.personID = passenger.personID
        WHERE person.locationID = (
            SELECT locationID
            FROM airplane
            WHERE airlineID = airline_id AND tail_num = tail_number
        )
    ) THEN
        LEAVE sp_main;
    END IF;

    UPDATE airplane
    SET locationID = airport_location_id
    WHERE airlineID = airline_id AND tail_num = tail_number;
    
    DELETE FROM flight WHERE flightID = ip_flightID;
END //
delimiter ;

-- [13] simulation_cycle()
-- -----------------------------------------------------------------------------
/* This stored procedure executes the next step in the simulation cycle.  The flight
with the smallest next time in chronological order must be identified and selected.
If multiple flights have the same time, then flights that are landing should be
preferred over flights that are taking off.  Similarly, flights with the lowest
identifier in alphabetical order should also be preferred.

If an airplane is in flight and waiting to land, then the flight should be allowed
to land, passengers allowed to disembark, and the time advanced by one hour until
the next takeoff to allow for preparations.

If an airplane is on the ground and waiting to takeoff, then the passengers should
be allowed to board, and the time should be advanced to represent when the airplane
will land at its next location based on the leg distance and airplane speed.

If an airplane is on the ground and has reached the end of its route, then the
flight crew should be recycled to allow rest, and the flight itself should be
retired from the system. */
-- -----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS simulation_cycle;
DELIMITER //
CREATE PROCEDURE simulation_cycle()
sp_main: BEGIN
    DECLARE v_flightID VARCHAR(50);
    DECLARE v_next_time TIME;
    DECLARE v_status VARCHAR(100);
    DECLARE v_progress INT;
    DECLARE v_routeID VARCHAR(50);
    DECLARE v_total_legs INT;

    SELECT f.flightID, f.next_time, f.airplane_status, f.progress, f.routeID
      INTO v_flightID, v_next_time, v_status, v_progress, v_routeID
      FROM flight f
      WHERE f.next_time IS NOT NULL
      ORDER BY 
          f.next_time ASC,
          CASE f.airplane_status
              WHEN 'in_flight' THEN 0
              WHEN 'on_ground' THEN 1
              ELSE 2
          END,
          f.flightID ASC
      LIMIT 1;
    
    IF v_flightID IS NULL THEN
         LEAVE sp_main;
    END IF;
    
    SELECT COUNT(*)
      INTO v_total_legs
      FROM route_path
      WHERE routeID = v_routeID;
    
    IF v_status = 'in_flight' THEN
         CALL flight_landing(v_flightID);
         CALL passengers_disembark(v_flightID);
         
         SELECT airplane_status, progress, next_time
           INTO v_status, v_progress, v_next_time
           FROM flight
           WHERE flightID = v_flightID;
         
         IF v_progress >= v_total_legs THEN
             CALL recycle_crew(v_flightID);
             CALL retire_flight(v_flightID);
         END IF;
         
    ELSEIF v_status = 'on_ground' THEN
         IF v_progress >= v_total_legs THEN
             CALL recycle_crew(v_flightID);
             CALL retire_flight(v_flightID);
         ELSE
             CALL passengers_board(v_flightID);
             CALL flight_takeoff(v_flightID);
         END IF;
    END IF;
    
END //
DELIMITER ;


-- [14] flights_in_the_air()
-- -----------------------------------------------------------------------------
/* This view describes where flights that are currently airborne are located.
We need to display what airports these flights are departing from, what airports
they are arriving at, the number of flights that are flying between the
departure and arrival airport, the list of those flights (ordered by their
flight IDs), the earliest and latest arrival times for the destinations and the
list of planes (by their respective flight IDs) flying these flights. */
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW flights_in_the_air AS
SELECT

    l.departure AS departing_from,
    l.arrival AS arriving_at,
    COUNT(f.flightID) AS num_flights,
    GROUP_CONCAT(f.flightID ORDER BY f.flightID SEPARATOR ',') AS flight_list,
    MIN(f.next_time) AS earliest_arrival,
    MAX(f.next_time) AS latest_arrival,
    GROUP_CONCAT(a.locationID ORDER BY f.flightID SEPARATOR ',') AS airplane_list
FROM flight AS f

JOIN route_path AS rp
    ON f.routeID = rp.routeID
   AND rp.sequence = f.progress

JOIN leg AS l
    ON rp.legID = l.legID

JOIN airplane AS a
    ON f.support_airline = a.airlineID
   AND f.support_tail = a.tail_num

WHERE f.airplane_status = 'in_flight'
GROUP BY l.departure, l.arrival;

-- [15] flights_on_the_ground()
-- ------------------------------------------------------------------------------
/* This view describes where flights that are currently on the ground are
located. We need to display what airports these flights are departing from, how
many flights are departing from each airport, the list of flights departing from
each airport (ordered by their flight IDs), the earliest and latest arrival time
amongst all of these flights at each airport, and the list of planes (by their
respective flight IDs) that are departing from each airport.*/
-- ------------------------------------------------------------------------------

CREATE OR REPLACE VIEW flights_on_the_ground AS
SELECT
    CASE WHEN f.progress = 0 THEN l.departure
         ELSE l.arrival
    END AS departing_from,
    COUNT(*) AS num_flights, GROUP_CONCAT(f.flightID ORDER BY f.flightID) AS flight_list, MIN(f.next_time) AS earliest_arrival, MAX(f.next_time) AS latest_arrival, GROUP_CONCAT(a.locationID ORDER BY f.flightID) AS airplane_list
FROM flight f

JOIN route_path rp
    ON f.routeID = rp.routeID
    AND rp.sequence = CASE WHEN f.progress = 0 THEN 1 ELSE f.progress END
JOIN leg l
    ON rp.legID = l.legID
JOIN airplane a
    ON f.support_airline = a.airlineID
   AND f.support_tail    = a.tail_num
WHERE f.airplane_status = 'on_ground'
GROUP BY
    CASE WHEN f.progress = 0 THEN l.departure
         ELSE l.arrival
    END;

-- [16] people_in_the_air()
-- -----------------------------------------------------------------------------
/* This view describes where people who are currently airborne are located. We 
need to display what airports these people are departing from, what airports 
they are arriving at, the list of planes (by the location id) flying these 
people, the list of flights these people are on (by flight ID), the earliest 
and latest arrival times of these people, the number of these people that are 
pilots, the number of these people that are passengers, the total number of 
people on the airplane, and the list of these people by their person id. */
-- -----------------------------------------------------------------------------
create or replace view people_in_the_air (departing_from, arriving_at, num_airplanes,
	airplane_list, flight_list, earliest_arrival, latest_arrival, num_pilots,
	num_passengers, joint_pilots_passengers, person_list) as
    
select 
    leg.departure as departing_from,
    leg.arrival as arriving_at,
    count(distinct airplane.locationID) as num_airplanes,
    group_concat(distinct airplane.locationID order by airplane.locationID) as airplane_list,
    group_concat(distinct flight.flightID order by flight.flightID) as flight_list,
    min(flight.next_time) as earliest_arrival,
    max(flight.next_time) as latest_arrival,
    sum(case when pilot.personID is not null then 1 else 0 end) as num_pilots,
    sum(case when passenger.personID is not null then 1 else 0 end) as num_passengers,
    count(person.personID) as joint_pilots_passengers,
    group_concat(person.personID order by person.personID) as person_list
    
from person
left join passenger on person.personID = passenger.personID
left join pilot on person.personID = pilot.personID
join location on person.locationID = location.locationID
join airplane on location.locationID = airplane.locationID
join flight on airplane.airlineID = flight.support_airline and airplane.tail_num = flight.support_tail
join route_path on flight.routeID = route_path.routeID and flight.progress = route_path.sequence
join leg on route_path.legID = leg.legID
where flight.airplane_status = 'in_flight'
group by leg.departure, leg.arrival;

-- [17] people_on_the_ground()
-- -----------------------------------------------------------------------------
/* This view describes where people who are currently on the ground and in an 
airport are located. We need to display what airports these people are departing 
from by airport id, location id, and airport name, the city and state of these 
airports, the number of these people that are pilots, the number of these people 
that are passengers, the total number people at the airport, and the list of 
these people by their person id. */
-- -----------------------------------------------------------------------------
create or replace view people_on_the_ground (departing_from, airport, airport_name,
	city, state, country, num_pilots, num_passengers, joint_pilots_passengers, person_list) as
select 
    airport.airportID as departing_from,
    airport.locationID as airport,
    airport.airport_name,
    airport.city,
    airport.state,
    airport.country,
    sum(case when pilot.personID is not null then 1 else 0 end) as num_pilots,
    sum(case when passenger.personID is not null then 1 else 0 end) as num_passengers,
    count(person.personID) as joint_pilots_passengers,
    group_concat(person.personID order by person.personID) as person_list
from person
left join passenger on person.personID = passenger.personID
left join pilot on person.personID = pilot.personID
join location on person.locationID = location.locationID
join airport on location.locationID = airport.locationID
group by airport.airportID, airport.locationID, airport.airport_name, airport.city, airport.state, airport.country;

-- [18] route_summary()
-- -----------------------------------------------------------------------------
/* This view will give a summary of every route. This will include the routeID, 
the number of legs per route, the legs of the route in sequence, the total 
distance of the route, the number of flights on this route, the flightIDs of 
those flights by flight ID, and the sequence of airports visited by the route. */
-- -----------------------------------------------------------------------------
create or replace view route_summary (route, num_legs, leg_sequence, route_length,
num_flights, flight_list, airport_sequence) as
-- DONE
-- select '_', '_', '_', '_', '_', '_', '_';
select
    r.routeID as route, count(rp.legID) as num_legs, group_concat(rp.legID order by rp.sequence separator ',') as leg_sequence, sum(l.distance) as route_length,
    (
        select count(distinct f.flightID) from flight f where f.routeID = r.routeID
    ) as num_flights, (
        select group_concat(distinct f.flightID order by f.flightID separator ',') from flight f where f.routeID = r.routeID
    ) as flight_list,
    group_concat(concat(l.departure, '->', l.arrival) order by rp.sequence separator ',') as airport_sequence
from route r join route_path rp on r.routeID = rp.routeID join leg l on rp.legID = l.legID group by r.routeID;

-- [19] alternative_airports()
-- -----------------------------------------------------------------------------
/* This view displays airports that share the same city and state. It should 
specify the city, state, the number of airports shared, and the lists of the 
airport codes and airport names that are shared both by airport ID. */
-- -----------------------------------------------------------------------------
create or replace view alternative_airports (city, state, country, num_airports,
	airport_code_list, airport_name_list) as
select city, state, country, count(*) as num_airports, 
	group_concat(airportID order by airportID) as airport_code_list,
	group_concat(airport_name order by airportID) as airport_name_list
from airport group by city, state, country having count(*) > 1;